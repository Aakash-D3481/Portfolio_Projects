---Data in the Database---
Exec Data_desc

---Find Constituency Names in a Particular State---
Exec State_Info 'Punjab'

---------------------------------------------------------
-- Enter your Requirements --

DECLARE @StateName NVARCHAR(50) = 'Punjab';
DECLARE @ElectionType NVARCHAR(50) = 'Vidhan Sabha';
DECLARE @AC_Name NVARCHAR(50) = 'AJNALA'
DECLARE @Year1 INT = 2017;
DECLARE @Year2 INT = 2022;
DECLARE @Party1 NVARCHAR(50) = 'INC';
DECLARE @Party2 NVARCHAR(50) = 'BJP';

-- Year 1 and Year 2 Results

DECLARE @SQL NVARCHAR(MAX) = 
'CREATE OR ALTER VIEW Year_1_and_Year_2_Results AS
SELECT * 
FROM Get_Election_Results(''' + @StateName + ''', ''' + @ElectionType + ''', ' + CAST(@Year1 AS NVARCHAR) + ', ' + CAST(@Year2 AS NVARCHAR) + ');';
EXEC sp_executesql @SQL;

-- Year 1 Results

SET @SQL = 
'CREATE OR ALTER VIEW Year_1_Results AS 
SELECT * 
FROM Get_Election_Results(''' + @StateName + ''', ''' + @ElectionType + ''', ' + CAST(@Year1 AS NVARCHAR) + ', NULL);';
EXEC sp_executesql @SQL;

-- Year 2 Results

SET @SQL = 
'CREATE OR ALTER VIEW Year_2_Results AS
SELECT *
FROM Get_Election_Results(''' + @StateName + ''', ''' + @ElectionType + ''', ' + CAST(@Year2 AS NVARCHAR) + ', NULL);';
EXEC sp_executesql @SQL;

-- Consistent Analysis for Party 1

SET @SQL = 
'CREATE OR ALTER VIEW Consistent_Analysis_Party_1 AS
SELECT *
FROM Get_Consistent_Analysis(''' + @Party1 + ''');';
EXEC sp_executesql @SQL;

-- Consistent Analysis for Party 2

SET @SQL = 
'CREATE OR ALTER VIEW Consistent_Analysis_Party_2 AS
SELECT *
FROM Get_Consistent_Analysis(''' + @Party2 + ''');';
EXEC sp_executesql @SQL;


-- Swing Analysis between Party 1 and Party 2

SET @SQL = 
'CREATE OR ALTER VIEW Swing_Analysis_Parties_V1 AS
SELECT *
FROM Get_Swing_Analysis(''' + @Party1 + ''', ''' + @Party2 + ''');';
EXEC sp_executesql @SQL;

-- Swing Analysis between Party 2 and Party 1

SET @SQL = 
'CREATE OR ALTER VIEW Swing_Analysis_Parties_V2 AS
SELECT *
FROM Get_Swing_Analysis(''' + @Party2 + ''', ''' + @Party1 + ''');';
EXEC sp_executesql @SQL;


-- Battleground Analysis between Party 1 and Party 2 for Year 1 and Year 2

SET @SQL = 
'CREATE OR ALTER VIEW Battleground_Analysis AS
SELECT *
FROM Get_Battleground_Analysis(''' + @Party2 + ''', ''' + @Party1 + ''', ' + CAST(@Year1 AS NVARCHAR) + ', ' + CAST(@Year2 AS NVARCHAR) + ');';
EXEC sp_executesql @SQL;

-- Abstract Analysis between Party 1 and Party 2

SET @SQL = 
'CREATE OR ALTER VIEW Abstract_Analysis AS
SELECT *
FROM Get_Abstract_Analysis(''' + @Party1 + ''', ''' + @Party2 + ''');';
EXEC sp_executesql @SQL;

------Polling Station Analysis------

-- Get Constituency_Results for Individual Years
SET @SQL =
'CREATE OR ALTER VIEW Constituency_Results_Year_1 AS
SELECT * 
FROM Get_Constituency_Results('''+ @StateName +''', '''+ @ElectionType +''', '''+ CAST(@Year1 AS NVARCHAR) +''', '''+ @AC_Name +''')';
EXEC sp_executesql @SQL;

-- Year 2
SET @SQL =
'CREATE OR ALTER VIEW Constituency_Results_Year_2 AS
SELECT * 
FROM Get_Constituency_Results('''+ @StateName +''', '''+ @ElectionType +''', '''+ CAST(@Year2 AS NVARCHAR) +''', '''+ @AC_Name +''')';
EXEC sp_executesql @SQL;

-- Mapping Both Years Side by Side
SET @SQL =
'CREATE OR ALTER VIEW Mapped_Constituencies AS
SELECT * 
FROM Get_Mapped_Constituencies()';
EXEC sp_executesql @SQL;

-- Constituency Consistent Analysis for Party 1
SET @SQL =
'CREATE OR ALTER VIEW Constituency_Consistent_Results_Party_1 AS
SELECT *
FROM Get_Constituency_Consistent_Results(''' + @Party1 + ''')';
EXEC sp_executesql @SQL;

-- Constituency Consistent Analysis for Party 2
SET @SQL =
'CREATE OR ALTER VIEW Constituency_Consistent_Results_Party_2 AS
SELECT *
FROM Get_Constituency_Consistent_Results(''' + @Party2 + ''')';
EXEC sp_executesql @SQL;

-- Constituency Swing Analysis V1
SET @SQL =
'CREATE OR ALTER VIEW Constituency_Swing_Results_V1 AS
SELECT *
FROM Get_Constituency_Swing_Results(''' + @Party1 + ''', ''' + @Party2 + ''')';
EXEC sp_executesql @SQL;

-- Constituency Swing Analysis V2
SET @SQL =
'CREATE OR ALTER VIEW Constituency_Swing_Results_V2 AS
SELECT *
FROM Get_Constituency_Swing_Results(''' + @Party2 + ''', ''' + @Party1 + ''')';
EXEC sp_executesql @SQL;

-- BattleGround and Safeground Analysis for Year 1
SET @SQL =
'CREATE OR ALTER VIEW Constituency_BattleGround_Results_Year_1 AS
SELECT *
FROM Get_Constituency_Battleground_Results_Year_1(''' + @Party1 + ''', ''' + @Party2 + ''')';
EXEC sp_executesql @SQL;

-- BattleGround and Safeground Analysis for Year 2
SET @SQL =
'CREATE OR ALTER VIEW Constituency_BattleGround_Results_Year_2 AS
SELECT *
FROM Get_Constituency_Battleground_Results_Year_2(''' + @Party1 + ''', ''' + @Party2 + ''')';
EXEC sp_executesql @SQL;

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
---Quick Access to State Level views---

Select * from Abstract_Analysis;
Select * from Year_1_and_Year_2_Results;
Select * from Year_1_Results;
Select * from Year_2_Results;
Select * from Consistent_Analysis_Party_1;
Select * from Consistent_Analysis_Party_2;
Select * from Swing_Analysis_Parties_V1;
Select * from Swing_Analysis_Parties_V2;
Select * from Battleground_Analysis;

---Polling Station Level---

Select * from Constituency_Results_Year_1;
Select * from Constituency_Results_Year_2;
Select * from Mapped_Constituencies;
Select * from Constituency_Consistent_Results_Party_1;
Select * from Constituency_Consistent_Results_Party_2;
Select * from Constituency_Swing_Results_V1;
Select * from Constituency_Swing_Results_V2;
Select * from Constituency_BattleGround_Results_Year_1;
Select * from Constituency_BattleGround_Results_Year_2;