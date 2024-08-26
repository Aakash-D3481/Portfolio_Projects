---Functions and Procedures--

--Creating a Procedure to get the Summary of Data available in database--
Create Procedure Data_desc
as
Begin
	Select distinct(t.State_Name), t.Election_Year, t.Election_Name, t.Total_Data
	from(
		select s.State_Name, y.Election_Year, e.Election_Name, count(s.State_Name) as Total_Data
		from Votes v
		join Election_Type e on e.Election_Type_ID = v.Election_Type_ID
		join Years y on y.Year_ID = v.Election_Year_ID
		join States s on s.State_ID = v.State_ID
		group by s.State_Name, y.Election_Year, e.Election_Name) as t
End
----------------
--Creating a Procedure to get the Consitituency Names of a Particular State--

Create Procedure State_Info 
	@State_Name varchar(50)
as
Begin
	Select s.State_Name, c.Constituency_Number, c.Constituency_Name
	from Constituencies c
	join States s on s.State_ID = c.State_ID
	where s.State_Name = @State_Name

End;

----------------------------------------------------------

---State LEVEL---------
--Procedure for Getting Summarized Election Data for any State--

Create or Alter Procedure Get_State_Election_Results
	@State_Name varchar(50),
	@Election_Name varchar(50),
	@Election_Year_1 int,
	@Election_Year_2 int = Null
As
Begin
	with Vote_shares as(
		SELECT s.State_Name, c.Constituency_Name, y.Election_Year, e.Election_Name, v.Parties, SUM(v.Votes) as Total_Votes,
		sum(v.Total_Valid_Votes) as Total_Votes_Per_Election,
		Cast(SUM(v.Votes) * 100.0 / sum(v.Total_Valid_Votes) as decimal (5,2)) as VS_perc
		FROM Votes v
		JOIN Constituencies c ON v.Constituency_Number = c.Constituency_Number AND v.State_ID = c.State_ID
		JOIN Years y ON v.Election_Year_ID = y.Year_ID
		JOIN Election_Type e ON v.Election_Type_ID = e.Election_Type_ID
		Join States s on s.State_ID = v.State_ID
		where s.State_Name = @State_Name and e.Election_Name = @Election_Name and y.Election_Year in (@Election_Year_1, Coalesce(@Election_Year_2, @Election_Year_1))
		GROUP BY s.State_Name, c.Constituency_Name, e.Election_Name, y.Election_Year, v.Parties),
	cte as(
	SELECT	*,
		Dense_Rank() OVER (Partition By Constituency_Name, Election_Year, Election_Name ORDER BY VS_perc DESC) as Party_Rank,
		(Case when Dense_Rank() OVER (Partition By Constituency_Name, Election_Year, Election_Name ORDER BY VS_perc DESC) = 1 Then Parties Else '-' End) as Winner
	FROM 
		Vote_shares)
	Select *,
	Max(Case when Party_Rank = 1 then VS_perc End) Over(PARTITION BY Constituency_Name, Election_Year)-
	MAX(Case when Party_Rank = 2 then VS_perc End) Over(PARTITION BY Constituency_Name, Election_Year) as Winning_Margin
	from cte;
End;

------Creating a Function----------

CREATE or Alter FUNCTION dbo.Get_Election_Results
(
    @State_Name NVARCHAR(100),
    @Election_Name NVARCHAR(100),
    @Year_1 INT,
    @Year_2 INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH Vote_shares AS
    (
        SELECT 
            s.State_Name, 
			c.Constituency_Number,
            c.Constituency_Name, 
            y.Election_Year, 
            e.Election_Name, 
            v.Parties, 
            SUM(v.Votes) as Total_Votes,
            sum(v.Total_Valid_Votes) as Total_Votes_Per_Election,
            CAST(SUM(v.Votes) * 100.0 / sum(v.Total_Valid_Votes) AS DECIMAL(5,2)) AS VS_perc
        FROM Votes v
        JOIN Constituencies c ON v.Constituency_Number = c.Constituency_Number AND v.State_ID = c.State_ID
        JOIN Years y ON v.Election_Year_ID = y.Year_ID
        JOIN Election_Type e ON v.Election_Type_ID = e.Election_Type_ID
        JOIN States s ON s.State_ID = v.State_ID
        WHERE s.State_Name = @State_Name 
          AND e.Election_Name = @Election_Name 
          AND y.Election_Year IN (@Year_1, ISNULL(@Year_2, @Year_1))
        GROUP BY 
            s.State_Name, 
			c.Constituency_Number,
            c.Constituency_Name, 
            e.Election_Name, 
            y.Election_Year, 
            v.Parties
    ),
    cte AS
    (
        SELECT *,
            DENSE_RANK() OVER (PARTITION BY Constituency_Number, Constituency_Name, Election_Year, Election_Name ORDER BY VS_perc DESC) AS Party_Rank,
            CASE 
                WHEN DENSE_RANK() OVER (PARTITION BY Constituency_Number, Constituency_Name, Election_Year, Election_Name ORDER BY VS_perc DESC) = 1 
                THEN Parties 
                ELSE '-' 
            END AS Winner
        FROM Vote_shares
    )
    SELECT *,
        MAX(CASE WHEN Party_Rank = 1 THEN VS_perc END) OVER(PARTITION BY Constituency_Number, Constituency_Name, Election_Year) - 
        MAX(CASE WHEN Party_Rank = 2 THEN VS_perc END) OVER(PARTITION BY Constituency_Number, Constituency_Name, Election_Year) AS Winning_Margin
    FROM cte
);

-----Creation of Analysis Views------
--Consistent Analysis--
CREATE or Alter FUNCTION dbo.Get_Consistent_Analysis
(
	@Party varchar(50)
)
RETURNS TABLE
AS
RETURN
(
	select 
	y1.Constituency_Number as Constituency_Number,
	y1.Constituency_Name AS Constituency_Name,
	y1.Winner AS Party,
	y1.Total_Votes as Total_Votes_Year_1,
	y2.Total_Votes as Total_Votes_Year_2,
	y1.VS_perc AS VS_perc_Year_1,
	y2.VS_perc AS VS_perc_Year_2,
	(y2.VS_perc - y1.VS_perc) AS VS_Margin_CHG,
	y1.Winning_Margin AS Winning_Margin_Year_1,
	y2.Winning_Margin AS Winning_Margin_Year_2,
	(y2.Winning_Margin - y1.Winning_Margin) AS Win_Margin_CHG
	from Year_1_Results y1
	full outer join Year_2_Results y2 on y1.Constituency_Number = y2.Constituency_Number
	where y1.Winner = @Party and y2.Winner = @Party
);

-----------------------------------------------------
--Swing Analysis--

CREATE FUNCTION dbo.Get_Swing_Analysis
(
	@Party_1 varchar(50),
	@Party_2 varchar(50)
)
RETURNS TABLE
AS
RETURN
(
	select 
	y1.Constituency_Name AS Constituency_Name,
	y1.Winner AS Party_Year_1,
	y2.Winner AS Party_Year_2,
	y2.VS_perc AS VS_perc_Year2_Party_2,
	y1.VS_perc AS VS_perc_Year1_Party_1,
	(y2.VS_perc - y1.VS_perc) AS VS_Margin_CHG,
	y1.Winning_Margin AS Winning_Margin_Year_1,
	y2.Winning_Margin AS Winning_Margin_Year_2,
	(y2.Winning_Margin - y1.Winning_Margin) AS Win_Margin_CHG
	from Year_1_Results y1
	full outer join Year_2_Results y2 on y1.Constituency_Name = y2.Constituency_Name
	where y1.Winner = @Party_1 and y2.Winner = @Party_2
);

--------------------------------
--BattleGround & SafeGround Analysis--

CREATE FUNCTION dbo.Get_Battleground_Analysis
(
	@Winner_1 varchar(50),
	@Winner_2 varchar(50),
	@Year_1 int,
	@Year_2 int
)
RETURNS TABLE
AS
RETURN
(
	select y.Election_Year, y.Constituency_Name, y.Winner, y.Winning_Margin,
	(Case when y.Winning_Margin >= 30 Then 'Safe' 
		when y.Winning_Margin <= 5 Then 'Battleground'
		when y.Winning_Margin Between 15 and 8 Then 'Unsure'
		else '-'
	End) as Constituencies_Results
	from Year_1_and_Year_2_Results y
	where Winner in (@Winner_1, @Winner_2) and y.Election_Year in (@Year_1, @Year_2)

);
-------------------------------------------

--Abstract Analysis--

CREATE FUNCTION dbo.Get_Abstract_Analysis
(
	@Party_1 varchar(50),
	@Party_2 varchar(50)
	
)
RETURNS TABLE
AS
RETURN
(
	select y.Election_Year, 
	Count(Case when y.Winner = @Party_1 then 1 END) as Party_1_Wins,
	Count(Case when y.Winner = @Party_2 then 1 END) as Party_2_Wins
	from Year_1_and_Year_2_Results y
	group by y.Election_Year

);

-------------------------------------------------------------------------------------
----Constituency Level Functions-------

---Get Constituency_Results for Year 1
CREATE FUNCTION dbo.Get_Constituency_Results
(
	@State_Name varchar(50),
	@Election_Name varchar(50),
	@Election_Year int,
	@Constituency_Name varchar(50)
	
)
RETURNS TABLE
AS
RETURN
(
	with Vote_Shares as(
	Select s.State_Name, e.Election_Name, y.Election_Year, c.Constituency_Name as AC_Name,
	v.SI_No, v.PS_No, v.Parties,v.Votes,
	DENSE_RANK() OVER(Partition By s.State_Name, e.Election_Name, y.Election_Year, c.Constituency_Name, v.PS_No Order by v.Votes Desc) as Party_Rank,
	v.Total_Valid_Votes as Total_Votes,
	Cast((v.Votes * 100.0) / v.Total_Valid_Votes as decimal(5,2)) as VS_Perc
	from Votes v
	join Constituencies c on c.Constituency_Number = v.Constituency_Number
	join States s on s.State_ID = v.State_ID
	join Election_Type e on e.Election_Type_ID = v.Election_Type_ID
	join Years y on y.Year_ID = v.Election_Year_ID
	where s.State_Name = @State_Name and c.Constituency_Name = @Constituency_Name and e.Election_Name = @Election_Name and y.Election_Year = @Election_Year)
	Select *,
	Max(Case when Party_Rank = 1 then VS_Perc End) over(Partition By Election_Year, AC_Name, PS_No) - 
	Max(Case when Party_Rank = 2 then VS_Perc End) over(Partition By Election_Year, AC_Name, PS_No) as Winning_Margin,
	(Case when Party_Rank = 1 then Parties else '-' End) as Winner
	from Vote_Shares

);

------------------------------
---Function for Mapping Constituency side by side---

CREATE FUNCTION dbo.Get_Mapped_Constituencies
(
	
)
RETURNS TABLE
AS
RETURN
(
	WITH Ranked_Year_1 AS (
	SELECT Election_Year AS Election_Year_1,
		AC_Name AS AC_Name_Year_1,
		SI_No AS SI_No_Year_1,
		PS_No AS PS_No_Year_1,
		Parties AS Parties_Year_1,
		Votes AS Votes_Year_1,
		Party_Rank as Party_Rank_Year_1,
		Total_Votes as Total_Votes_Year_1,
		VS_Perc as VS_Perc_Year_1,
		Winning_Margin as Winning_Margin_Year_1,
		Winner as Winner_Year_1,
		ROW_NUMBER() OVER (PARTITION BY PS_No ORDER BY Votes DESC) AS RN
		FROM Constituency_Results_Year_1),
	Ranked_Year_2 AS (
	SELECT 
		Election_Year AS Election_Year_2,
		AC_Name AS AC_Name_Year_2,
		SI_No AS SI_No_Year_2,
		PS_No AS PS_No_Year_2,
		Parties AS Parties_Year_2,
		Votes AS Votes_Year_2,
		Party_Rank as Party_Rank_Year_2,
		Total_Votes as Total_Votes_Year_2,
		VS_Perc as VS_Perc_Year_2,
		Winning_Margin as Winning_Margin_Year_2,
		Winner as Winner_Year_2,
		ROW_NUMBER() OVER (PARTITION BY PS_No ORDER BY Votes DESC) AS RN
	FROM Constituency_Results_Year_2
	)
	SELECT r14.Election_Year_1, r14.AC_Name_Year_1, r14.SI_No_Year_1, r14.PS_No_Year_1, r14.Parties_Year_1, r14.Votes_Year_1, 
			r14.Party_Rank_Year_1,
			r14.Total_Votes_Year_1,
			r14.VS_Perc_Year_1,
			r14.Winning_Margin_Year_1,
			r14.Winner_Year_1,
		r19.Election_Year_2, r19.AC_Name_Year_2, r19.SI_No_Year_2, r19.PS_No_Year_2, r19.Parties_Year_2, r19.Votes_Year_2,
			r19.Party_Rank_Year_2,
			r19.Total_Votes_Year_2,
			r19.VS_Perc_Year_2,
			r19.Winning_Margin_Year_2,
			r19.Winner_Year_2
	FROM Ranked_Year_1 r14
	FULL OUTER JOIN Ranked_Year_2 r19 ON 
		r14.PS_No_Year_1 = r19.PS_No_Year_2 AND r14.RN = r19.RN

);

------------------------------------------------------------
---Function for Consistency_Analysis---------

CREATE FUNCTION dbo.Get_Constituency_Consistent_Results
(
	@Party_Name varchar(50)
	
)
RETURNS TABLE
AS
RETURN
(
	select 
	AC_Name_Year_1 AS Constituency_Name,
	PS_No_Year_1 as PS_Year_1,
	PS_No_Year_2 as PS_Year_2,
	Winner_Year_1 AS Party,
	Total_Votes_Year_1 as Total_Votes_Year_1,
	Total_Votes_Year_2 as Total_Votes_Year_2,
	VS_Perc_Year_1 AS VS_perc_Year_1,
	VS_Perc_Year_2 AS VS_perc_Year_2,
	(VS_Perc_Year_2 - VS_Perc_Year_1) AS VS_Margin_CHG,
	Winning_Margin_Year_1 AS Winning_Margin_Year_1,
	Winning_Margin_Year_2 AS Winning_Margin_Year_2,
	(Winning_Margin_Year_2 - Winning_Margin_Year_1) AS Win_Margin_CHG
	from Mapped_Constituencies
	where Winner_Year_1 = @Party_Name and Winner_Year_2 = @Party_Name

);

------------------------------------------------------------
---Function for Swing Analysis---

CREATE or Alter FUNCTION dbo.Get_Constituency_Swing_Results
(
	@Party_Name_1 varchar(50),
	@Party_Name_2 varchar(50)
	
)
RETURNS TABLE
AS
RETURN
(
	select 
	AC_Name_Year_1 AS Constituency_Name,
	PS_No_Year_1 as PS_Year_1,
	PS_No_Year_2 as PS_Year_2,
	Winner_Year_1 AS Winning_Party_Year_1,
	Winner_Year_2 AS Winning_Party_Year_2,
	VS_Perc_Year_2 AS VS_perc_Year_2,
	VS_Perc_Year_1 AS VS_perc_Year_1,
	(VS_Perc_Year_2 - VS_Perc_Year_1) AS VS_Margin_CHG,
	Winning_Margin_Year_2 AS Winning_Margin_Year_2,
	Winning_Margin_Year_1 AS Winning_Margin_Year_1,
	(Winning_Margin_Year_2 - Winning_Margin_Year_1) AS Win_Margin_CHG
	from Mapped_Constituencies
	where Winner_Year_1 = @Party_Name_1 and Winner_Year_2 = @Party_Name_2

);

---------------------------------------------------------
---Function for BattleGround and Safeground Analysis---
---Year 1----
CREATE FUNCTION dbo.Get_Constituency_Battleground_Results_Year_1
(
	@Party_1 varchar(50),
	@Party_2 varchar(50)
	
)
RETURNS TABLE
AS
RETURN
(
	select Election_Year,State_Name, AC_Name, PS_No, Winner, Winning_Margin,
	(Case when Winning_Margin >= 30 Then 'Safe' 
		when Winning_Margin <= 5 Then 'Battleground'
		when Winning_Margin Between 15 and 8 Then 'Unsure'
		else '-'
End) as Constituencies_Results
from Constituency_Results_Year_1
where Winner in (@Party_1, @Party_2)

);

---Year 2----
CREATE FUNCTION dbo.Get_Constituency_Battleground_Results_Year_2
(
	@Party_1 varchar(50),
	@Party_2 varchar(50)
	
)
RETURNS TABLE
AS
RETURN
(
	select Election_Year,State_Name, AC_Name, PS_No, Winner, Winning_Margin,
	(Case when Winning_Margin >= 30 Then 'Safe' 
		when Winning_Margin <= 5 Then 'Battleground'
		when Winning_Margin Between 15 and 8 Then 'Unsure'
		else '-'
End) as Constituencies_Results
from Constituency_Results_Year_2
where Winner in (@Party_1, @Party_2)

);

----------------------------------------------------------------------------------