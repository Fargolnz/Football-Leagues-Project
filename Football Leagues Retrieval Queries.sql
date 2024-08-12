--- Football Leagues Retrieval Queries ---


--- (1) فهرست بازیکنان اولیه هر تیم در بازی ---
SELECT
    t.TeamName,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    m.MatchID,
    m.MatchDate,
    pim.Position,
    pim.MatchRate
FROM
    PlayerInMatch pim
JOIN
    Player p ON pim.PlayerSsn = p.PlayerSsn
JOIN
    Team t ON (pim.PlayerSsn IN (
        SELECT PlayerSsn
        FROM PlayerContract
        WHERE DestinationTeamID = t.TeamID
    ))
JOIN
    Match m ON pim.MatchID = m.MatchID
JOIN
	MatchEvents me ON me.MatchID = m.MatchID
JOIN
	Event e ON me.EventID = e.EventID
WHERE
    pim.Fixed = 1
ORDER BY
    m.MatchID,
    t.TeamName,
    p.Lname;



--- (2) آمار فنی مربوط به بازی برای هر یک از تیم‌های شرکت کننده در آن بازی ---
SELECT 
    m.MatchID,
    m.MatchDate,
    ht.TeamName AS HomeTeam,
    pt.HomeGoalsNum AS HomeGoals,
    t.TeamName AS AwayTeam,
    pt.AwayGoalsNum AS AwayGoals,
    pt.HomeFormation,
    pt.AwayFormation,
    SUM(CASE WHEN e.EventType = 'Yellow Card' AND pt.HomeTeamID = pc.DestinationTeamID THEN 1 ELSE 0 END) AS HomeYellowCards,
    SUM(CASE WHEN e.EventType = 'Red Card' AND pt.HomeTeamID = pc.DestinationTeamID THEN 1 ELSE 0 END) AS HomeRedCards,
    SUM(CASE WHEN e.EventType = 'Yellow Card' AND pt.AwayTeamID = pc.DestinationTeamID THEN 1 ELSE 0 END) AS AwayYellowCards,
    SUM(CASE WHEN e.EventType = 'Red Card' AND pt.AwayTeamID = pc.DestinationTeamID THEN 1 ELSE 0 END) AS AwayRedCards
FROM 
    Match m
LEFT JOIN  
    Participates pt ON m.MatchID = pt.MatchID
LEFT JOIN 
    Team ht ON pt.HomeTeamID = ht.TeamID
LEFT JOIN 
    Team T ON pt.AwayTeamID = t.TeamID
LEFT JOIN 
    MatchEvents me ON m.MatchID = me.MatchID
LEFT JOIN 
    Event e ON me.EventID = e.EventID
LEFT JOIN 
    Player p ON me.PerformerPlayer = p.PlayerSsn
LEFT JOIN 
    PlayerContract pc ON p.PlayerSsn = pc.PlayerSsn
GROUP BY 
    m.MatchID, m.MatchDate, ht.TeamName, pt.HomeGoalsNum, t.TeamName, pt.AwayGoalsNum, pt.HomeFormation, pt.AwayFormation
ORDER BY 
    m.MatchID;



--- (3) گل‌زنان یک بازی ---
SELECT 
    m.MatchID,
    m.MatchDate,
    t.TeamName,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    e.EventTime,
	e.EventType
FROM 
    Match m
JOIN 
    MatchEvents me ON m.MatchID = me.MatchID
JOIN 
    Event e ON me.EventID = e.EventID
JOIN 
    Player p ON me.PerformerPlayer = p.PlayerSsn
JOIN 
    PlayerContract pc ON p.PlayerSsn = pc.PlayerSsn
JOIN 
    Team t ON pc.DestinationTeamID = t.TeamID
WHERE 
    e.EventType = 'Goal'
ORDER BY 
    m.MatchDate, m.MatchID, e.EventTime;



--- (4) بازیکنان اخطاری یک بازی ---
SELECT 
    m.MatchID,
    m.MatchDate,
    t.TeamName,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    e.EventTime,
    e.EventType AS CardType
FROM 
    Match m
JOIN 
    MatchEvents me ON m.MatchID = me.MatchID
JOIN 
    Event e ON me.EventID = e.EventID
JOIN 
    Player p ON me.PerformerPlayer = p.PlayerSsn
JOIN 
    PlayerContract pc ON p.PlayerSsn = pc.PlayerSsn
JOIN 
    Team t ON pc.DestinationTeamID = t.TeamID
WHERE 
    e.EventType IN ('Yellow Card', 'Red Card')
ORDER BY 
    m.MatchDate, m.MatchID, e.EventTime;



--- (5) آمار تعویض‌های یک بازی ---
SELECT 
    m.MatchID,
    m.MatchDate,
    t.TeamName,
    p_out.Fname AS OutgoingPlayerFirstName,
    p_out.Lname AS OutgoingPlayerLastName,
    p_in.Fname AS IncomingPlayerFirstName,
    p_in.Lname AS IncomingPlayerLastName,
    e.EventTime
FROM 
    Match m
JOIN 
    MatchEvents me ON m.MatchID = me.MatchID
JOIN 
    Event e ON me.EventID = e.EventID
JOIN 
    Player p_out ON me.PerformerPlayer = p_out.PlayerSsn
JOIN 
    Player p_in ON me.InvolvedPlayer = p_in.PlayerSsn
JOIN 
    PlayerContract pc_out ON p_out.PlayerSsn = pc_out.PlayerSsn
JOIN 
    PlayerContract pc_in ON p_in.PlayerSsn = pc_in.PlayerSsn
JOIN 
    Team t ON pc_out.DestinationTeamID = t.TeamID
WHERE 
    e.EventType = 'Substitution'
ORDER BY 
    m.MatchDate, m.MatchID, e.EventTime;



--- (6) تاریخچه حضور بازیکن در تیم‌های مختلف ---
SELECT
	p.Fname as 'First name',
	p.Lname as 'Last name',
    t.TeamName,
    pc.ContractDate AS ContractStartDate,
    pc.TerminationDate AS ContractEndDate,
    pc.Salary,
    COUNT(pm.MatchID) AS MatchesPlayed,
    SUM(CASE WHEN e.EventType = 'Goal' THEN 1 ELSE 0 END) AS GoalsScored,
    SUM(CASE WHEN e.EventType = 'Yellow Card' THEN 1 ELSE 0 END) AS YellowCards,
    SUM(CASE WHEN e.EventType = 'Red Card' THEN 1 ELSE 0 END) AS RedCards,
    AVG(pm.MatchRate) AS AverageRating,
    SUM(CASE WHEN pm.Fixed = 1 THEN 1 ELSE 0 END) AS Fixed,
    SUM(CASE WHEN pm.Fixed = 0 THEN 1 ELSE 0 END) AS Substitutions
FROM 
    PlayerContract pc
JOIN 
    Team t ON pc.DestinationTeamID = t.TeamID
JOIN 
    PlayerInMatch pm ON pc.PlayerSsn = pm.PlayerSsn
JOIN 
    Match m ON pm.MatchID = m.MatchID
LEFT JOIN 
    MatchEvents me ON pm.MatchID = me.MatchID AND me.PerformerPlayer = pc.PlayerSsn
JOIN
  Event e ON me.EventID = e.EventID
JOIN
	Player p ON pm.PlayerSsn = p.PlayerSsn
GROUP BY 
    p.Fname, p.Lname, pc.PlayerSsn, t.TeamName, pc.ContractDate, pc.TerminationDate, pc.Salary;



--- (7) تاریخچه حضور بازیکن در انواع لیگ‌های مختلف ---
SELECT
	p.PlayerSsn,
    l.LeagueName,
    t.TeamName,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    DATEDIFF(DAY, pc.ContractDate, GETDATE()) AS TotalDaysInLeague,
    SUM(CASE WHEN e.EventType = 'Goal' THEN 1 ELSE 0 END) AS GoalsScored,
    AVG(pm.MatchRate) AS AverageRating
FROM 
    League l
JOIN 
    Ranking r ON l.LeagueID = r.LeagueID
JOIN
  Team t ON r.TeamID = t.TeamID
JOIN 
    PlayerContract pc ON t.TeamID = pc.DestinationTeamID
JOIN 
    Player p ON pc.PlayerSsn = p.PlayerSsn
JOIN 
    PlayerInMatch pm ON p.PlayerSsn = pm.PlayerSsn
JOIN 
    Match m ON pm.MatchID = m.MatchID
LEFT JOIN 
    MatchEvents me ON pm.MatchID = me.MatchID AND me.PerformerPlayer = p.PlayerSsn
JOIN
  Event e ON me.EventID = e.EventID
GROUP BY 
    p.PlayerSsn, pc.ContractDate, l.LeagueName, t.TeamName, p.Fname, p.Lname;



--- (8) آمار بازی‌های انجام شده یک تیم در یک نوع لیگ ---
	SELECT
  m.LeagueWeek,
  t.TeamName AS 'Home Team name',
  t2.TeamName as 'Away Team name',
  pt.HomeFormation 'Team format',
  pt.HomeGoalsNum as 'Home Team Goals number',
  pt.AwayGoalsNum as 'Away Goals number',
  SUM(CASE WHEN e.EventType = 'Yellow Card' AND pm.PlayerSsn = me.PerformerPlayer AND pm.MatchID = m.MatchID AND pc.DestinationTeamID = 2 THEN 1 ELSE 0 END) AS YellowCards,
  SUM(CASE WHEN e.EventType = 'Red Card' AND pm.PlayerSsn = me.PerformerPlayer AND pm.MatchID = m.MatchID AND pc.DestinationTeamID = 2 THEN 1 ELSE 0 END) AS RedCards
FROM
    Event e
left JOIN
  MatchEvents me ON me.EventID = e.EventID
left JOIN
  PlayerInMatch pm ON pm.PlayerSsn = me.PerformerPlayer
left JOIN
  PlayerContract pc ON pc.PlayerSsn = pm.PlayerSsn
left JOIN
  Team t ON t.TeamID = pc.DestinationTeamID
left JOIN
  Participates pt ON pt.HomeTeamID = t.TeamID
left JOIN
  Team t2 ON t2.TeamID = pt.AwayTeamID
left JOIN
  Match m ON m.MatchID = pt.MatchID
left JOIN
  League l ON l.LeagueID = m.LeagueID
where 
  (pt.HomeTeamID = 2 OR pt.AwayTeamID = 2) and l.LeagueID = 2 and pm.MatchID = me.MatchID and e.EventID = me.EventID
Group by 
  m.LeagueWeek,
  t.TeamName,
  t2.TeamName,
  pt.HomeFormation,
  pt.HomeGoalsNum,
  pt.AwayGoalsNum
order by
  m.LeagueWeek;



--- (9) تاریخچه سرمربیان تیم ---
SELECT
	t.TeamName,
    ts.Fname, 
    ts.Lname, 
    ts.BirthDate,
    ts.Age, 
    ts.PhoneNumber, 
    ts.Address, 
    tsc.ContractDate, 
    tsc.ContractPeriod, 
    tsc.TerminationDate, 
    tsc.Salary,
    r.GamesPlayed,
    r.Wins AS Wins,
    r.Draws AS Draws,
    r.Losts AS Losses,
    r.GoalsFor,
    r.GoalsAgainst,
    SUM(CASE WHEN e.EventType = 'Yellow Card' AND (t.TeamID = pt.HomeTeamID OR t.TeamID = pt.AwayTeamID)  THEN 1 ELSE 0 END) AS YellowCards,
    SUM(CASE WHEN e.EventType = 'Red Card' AND (t.TeamID = pt.HomeTeamID OR t.TeamID = pt.AwayTeamID) THEN 1 ELSE 0 END) AS RedCards
FROM 
    TechnicalStaff ts
JOIN 
    TechnicalStaffContract tsc ON ts.TechnicalStaffSsn = tsc.TechnicalStaffSsn
JOIN 
    Team t ON tsc.DestinationTeamID = t.TeamID
JOIN
	Ranking r ON r.TeamID = t.TeamID
JOIN
	League l ON r.LeagueID = l.LeagueID
JOIN
	Match m ON m.LeagueID = l.LeagueID
JOIN 
	MatchEvents me ON me.MatchID = m.MatchID
JOIN
	Event e ON e.EventID = me.EventID
JOIN
	Participates pt ON pt.MatchID = m.MatchID
WHERE 
    ts.TechnicalStaffRole = 'Coach' AND tsc.ContractDate <= GETDATE() AND (tsc.TerminationDate IS NULL OR tsc.TerminationDate > GETDATE())

Group by  t.TeamName,  ts.Fname, ts.Lname, ts.BirthDate, ts.Age, ts.PhoneNumber, ts.Address, tsc.ContractDate, tsc.ContractPeriod, tsc.TerminationDate,  tsc.Salary, r.GamesPlayed, r.Wins, r.Draws, r.Losts, r.GoalsFor, r.GoalsAgainst
ORDER BY 
    tsc.ContractDate DESC;



--- (10) آمار فنی بازیکنان کنونی یک تیم به همراه اطلاعات قرارداد آنها ---
SELECT 
  p.PlayerSsn,
    p.Fname, 
    p.Lname, 
    p.Weight, 
    p.Height, 
    pc.ContractDate, 
    pc.ContractPeriod, 
    pc.TerminationDate, 
    pc.Salary, 
    pc.ShirtNumber,
    (SELECT COUNT(*) FROM PlayerInMatch pim WHERE pim.PlayerSsn = p.PlayerSsn) AS TotalMatches
FROM 
    Player p
JOIN 
    PlayerContract pc ON p.PlayerSsn = pc.PlayerSsn
WHERE 
    pc.DestinationTeamID = 2 AND pc.TerminationDate > GETDATE()
ORDER BY 
    p.Fname, p.Lname;



--- (11) آمار سرمربی فعلی تیم به همراه اطلاعات قرارداد وی ---
SELECT
    ts.TechnicalStaffSsn,
    ts.Fname AS CoachFirstName,
    ts.Lname AS CoachLastName,
    tsf.ContractDate,
    tsf.TerminationDate,
    tsf.Salary,
    r.GamesPlayed AS 'Games Coached',
    SUM(CASE WHEN e.EventType = 'Goal' THEN 1 ELSE 0 END) AS Goals,
    SUM(CASE WHEN e.EventType IN ('Yellow Card', 'Red Card') THEN 1 ELSE 0 END) AS TotalWarnings
FROM
    TechnicalStaffContract tsf
JOIN
    TechnicalStaff ts ON tsf.TechnicalStaffSsn = ts.TechnicalStaffSsn
JOIN
    Participates p ON tsf.DestinationTeamID = p.HomeTeamID OR tsf.DestinationTeamID = p.AwayTeamID
LEFT JOIN
    MatchEvents me ON p.MatchID = me.MatchID
LEFT JOIN
    Event e ON me.EventID = e.EventID
JOIN
	Ranking r ON r.TeamID = tsf.DestinationTeamID
WHERE
    ts.TechnicalStaffRole = 'Coach'
GROUP BY
	r.GamesPlayed,
    ts.TechnicalStaffSsn,
    ts.Fname,
    ts.Lname,
    tsf.ContractDate,
    tsf.TerminationDate,
    tsf.Salary;



--- (12) آمار کادر فنی فعلی تیم به همراه سمت و اطلاعات قرارداد آنها ---
SELECT
    ts.TechnicalStaffSsn,
    ts.Fname AS 'Staff First Name',
    ts.Lname AS 'Staff Last Name',
    ts.TechnicalStaffRole AS 'Technical Staff Role',
    tsf.ContractDate,
    tsf.TerminationDate,
    tsf.Salary
FROM
    TechnicalStaff ts
JOIN
    TechnicalStaffContract tsf ON ts.TechnicalStaffSsn = tsf.TechnicalStaffSsn



--- (13) آمار هر کدام از بازیکنان خریداری شده توسط یک تیم در یک بازه زمانی مشخص ---
SELECT 
    pc.PlayerSsn,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    pc.ContractDate,
    pc.TerminationDate,
    pc.Salary,
    t.TeamName AS 'Current team',
    COALESCE(t2.TeamName, '---') AS 'Previous Team name'
FROM 
    PlayerContract pc
JOIN 
    Player p ON pc.PlayerSsn = p.PlayerSsn
JOIN 
    Team t ON pc.DestinationTeamID = t.TeamID
JOIN 
    Team t2 ON pc.PreviousTeamID = t2.TeamID
WHERE 
    pc.ContractDate >= '2020-02-01' AND pc.ContractDate <= '2021-12-01';



--- (14) آمار تمامی قراردادهای بازیکنان با تیم‌ها طی یک بازه زمانی مشخص ---
SELECT 
    pc.PlayerSsn,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    pc.ContractDate,
    pc.TerminationDate,
    pc.Salary,
    t.TeamName AS 'Team'
FROM 
    PlayerContract pc
JOIN 
    Player p ON pc.PlayerSsn = p.PlayerSsn
JOIN 
    Team t ON pc.DestinationTeamID = t.TeamID
JOIN 
    Team t2 ON pc.PreviousTeamID = t2.TeamID
WHERE 
    pc.ContractDate >= '2020-01-01' AND pc.ContractDate <= '2021-12-01';



--- (15) آمار تمامی قراردادهای اعضاء کادر فنی با تیم‌ها طی یک بازه زمانی مشخص ---
SELECT
    pf.Fname AS PersonnelFirstName,
    pf.Lname AS PersonnelLastName,
    pf.TechnicalStaffRole AS PersonnelRole,
    t.TeamName,
    tc.ContractDate,
	tc.TerminationDate,
    tc.TechnicalStaffSsn,
    tc.Salary
FROM
    TechnicalStaffContract tc
JOIN
    TechnicalStaff pf ON tc.TechnicalStaffSsn = pf.TechnicalStaffSsn
JOIN
    Team t ON tc.DestinationTeamID = t.TeamID
WHERE
    tc.ContractDate >= '2020-01-01' AND tc.ContractDate <= '2021-01-01';



--- (16) مبلغ هزینه کلی پرداختی هر تیم به بازیکنان فعلی ---
SELECT
    t.TeamName,
    SUM(pc.Salary) AS TotalPaymentToPlayers
FROM
    PlayerContract pc
JOIN
    Team t ON pc.DestinationTeamID = t.TeamID
where 
	pc.TerminationDate > GETDATE()
GROUP BY
    t.TeamName;



--- (17) مبلغ هزینه کلی پرداختی هر تیم به اعضا فعلی کادر فنی ---
SELECT
    t.TeamName,
    SUM(tc.Salary) AS TotalPaymentToStaff
FROM
    TechnicalStaffContract tc
JOIN
    Team t ON tc.DestinationTeamID = t.TeamID
where 
	tc.TerminationDate > GETDATE()
GROUP BY
    t.TeamName;



--- (18) جدول لیگ ---
SELECT 
	l.LeagueName,
	l.Season,
    t.TeamName,
    r.GamesPlayed,
    r.Wins,
    r.Draws,
    r.Losts,
    r.GoalsFor,
    r.GoalsAgainst,
    r.GoalsDiffrence,
    r.TeamRate,
	SUM(CASE WHEN e.EventType = 'Yellow Card' AND (t.TeamID = pt.HomeTeamID OR t.TeamID = pt.AwayTeamID)  THEN 1 ELSE 0 END) AS YellowCards,
    SUM(CASE WHEN e.EventType = 'Red Card' AND (t.TeamID = pt.HomeTeamID OR t.TeamID = pt.AwayTeamID) THEN 1 ELSE 0 END) AS RedCards
FROM 
    Team t
JOIN 
    Ranking r ON t.TeamID = r.TeamID
JOIN
  League l ON r.LeagueID = l.LeagueID
JOIN
	Match m ON m.LeagueID = l.LeagueID
JOIN
	MatchEvents me ON me.MatchID = m.MatchID
JOIN
	Event e On e.EventID = me.EventID
JOIN	
	Participates pt ON pt.MatchID = m.MatchID
WHERE
  l.LeagueID = 2 AND Season = '2022-2023'
group by
		l.LeagueName,
	l.Season,
    t.TeamName,
    r.GamesPlayed,
    r.Wins,
    r.Draws,
    r.Losts,
    r.GoalsFor,
    r.GoalsAgainst,
    r.GoalsDiffrence,
    r.TeamRate

ORDER BY 
      r.TeamRate DESC,
    GoalsDiffrence DESC;



--- (19) آمار بازی‌های انجام شده در یک لیگ ---
SELECT
    m.MatchDate,
    s.StadiumName,
    t.TeamName AS HomeTeam,
    t2.TeamName AS AwayTeam,
    p.HomeGoalsNum AS 'Home Team Goals',
    p.AwayGoalsNum AS 'Away Team Goals',
  (SELECT COUNT(*) FROM Ticket ti WHERE ti.MatchID = m.MatchID) AS 'The number of spectators',
  (SELECT Sum(ti.Price) FROM Ticket ti WHERE ti.MatchID = m.MatchID) AS 'Profit from ticket sales',
    re.Fname AS 'Referee First Name',
    re.Lname AS 'Referee Last Name',
  rf.RefreeRole,
    su.Fname AS 'Supervisor First Name',
    su.Lname AS 'Supervisor Last Name'
FROM
    Participates p
JOIN
    Team t ON p.HomeTeamID = t.TeamID
JOIN
    Team t2 ON p.AwayTeamID = t2.TeamID
JOIN
    Match m ON m.MatchID = p.MatchID
JOIN
    RefreeTeam rf ON m.MatchID = rf.MatchID
JOIN
  stadium s ON m.StadiumID = s.StadiumID
JOIN
  Ticket ti ON m.MatchID = ti.MatchID
JOIN
    Referee re ON rf.RefereeSsn = re.RefereeSsn
JOIN
  SuperVisorTeam sut ON m.MatchID = sut.MatchID 
JOIN
  SuperVisor su ON sut.SuperVisorSsn = su.SuperVisorSsn

Group by m.MatchDate, s.StadiumName, t.TeamName, t2.TeamName, m.MatchID, p.HomeGoalsNum, p.AwayGoalsNum ,re.Fname, re.Lname, rf.RefreeRole, su.Fname, su.Lname;



--- (20) آمار فنی بازیکنان شاغل در یک لیگ ---
SELECT
    t.TeamName,
    p.Fname AS PlayerFirstName,
    p.Lname AS PlayerLastName,
    COUNT(pm.MatchID) AS MatchesPlayed,
    SUM(CASE WHEN e.EventType = 'Goal' THEN 1 ELSE 0 END) AS GoalsScored,
    SUM(CASE WHEN e.EventType = 'Yellow Card' THEN 1 ELSE 0 END) AS YellowCards,
    SUM(CASE WHEN e.EventType = 'Red Card' THEN 1 ELSE 0 END) AS RedCards,
    AVG(pm.MatchRate) AS AverageRating
FROM
    Team t
JOIN
    PlayerContract pc ON t.TeamID = pc.DestinationTeamID
JOIN
    Player p ON pc.PlayerSsn = p.PlayerSsn
JOIN
    PlayerInMatch pm ON p.PlayerSsn = pm.PlayerSsn
JOIN
    Match m ON pm.MatchID = m.MatchID
JOIN
    MatchEvents me ON pm.MatchID = me.MatchID AND me.PerformerPlayer = p.PlayerSsn
JOIN
  Event e ON me.EventID = e.EventID
GROUP BY
    t.TeamName, p.FName, p.LName;



--- (21) بازیکنان محروم از یک هفته از لیگ ---
SELECT
    p.FName AS PlayerFirstName,
    p.LName AS PlayerLastName,
    t.TeamName,
	e.EventType,
	m.LeagueWeek+1 as LeagueWeek
FROM
    Player p
JOIN
    PlayerContract pc ON p.PlayerSsn = pc.PlayerSsn
JOIN
    Team t ON pc.DestinationTeamID = t.TeamID
JOIN
    PlayerInMatch pm ON p.PlayerSsn = pm.PlayerSsn
JOIN
    Match m ON pm.MatchID = m.MatchID
JOIN
    MatchEvents me ON pm.MatchID = me.MatchID AND me.PerformerPlayer = p.PlayerSsn
JOIN
  Event e On me.EventID = e.EventID
WHERE
    (e.EventType = 'Red Card') OR ((SELECT COUNT(*) FROM MatchEvents WHERE PerformerPlayer = p.PlayerSsn AND m.LeagueWeek <= 3  AND  e.EventType = 'Yellow Card') >= 3);