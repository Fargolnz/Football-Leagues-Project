--- Football Leagues Tables Queries ---

create table League(
	LeagueID INT primary key,
	LeagueName varchar(255) not null,
	LeagueType varchar(255) not null,
	Season varchar(255)
);

create table Team(
	TeamID Int primary key,
	TeamName varchar(255) not null,
	FoundationYear varchar(255)
);

create table stadium(
	StadiumID INT primary key,
	StadiumName varchar(255) not null,
	StadiumType varchar(255),
	StadiumAddress varchar(255),
	VIPSeatsNum INT,
	FirstFloorSeatsNum INT,
	SecondFloorSeatsNum INT,
	Capacity as (FirstFloorSeatsNum + SecondFloorSeatsNum + VIPSeatsNum)
);

create table Match(
	MatchID INT primary key,
	LeagueID INT references League(LeagueID)
	on update cascade	on delete cascade not null,
	StadiumID INT references Stadium(StadiumID)
	on update cascade	on delete cascade not null,
	MatchDate varchar(255) not null,
	LeagueWeek INT not null
);

create table Ranking(
	LeagueID INT references League(LeagueID)
	on update cascade	on delete cascade,
	TeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	GamesPlayed Int,
	Wins INT,
	Draws Int,
	Losts Int,
	GoalsFor INT,
	GoalsAgainst INT,
	GoalsDiffrence as (GoalsFor + GoalsAgainst),
	TeamRate as ((Wins*3) + Draws),
	primary key (LeagueID, TeamID)
);

create table Participates(
	MatchID INT references Match(MatchID)
	on update cascade	on delete cascade,
	HomeTeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	AwayTeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	HomeFormation varchar(255),
	AwayFormation varchar(255),
	HomeGoalsNum INT,
	AwayGoalsNum INT,
	HomeScore INT,
	AwayScore INT,
	Primary key (MatchID, HomeTeamID, AwayTeamID)
);

create table Ticket(
	TicketID int,
	MatchID INT references Match(MatchID)
	on update cascade	on delete cascade,
	SeatType varchar(255),
	SellDate varchar(255),
	Price INT,
	PurchaserSsn varchar(255),
	PurchaserFname varchar(255),
	PurchaserLname varchar(255),
	PurchaserAge varchar(255),
	PurchaserPhoneNumber varchar(255),
	Primary key (TicketID, MatchID)
);

Create table TechnicalStaff(
	TechnicalStaffSsn varchar(255) Primary key,
	TechnicalStaffRole varchar(255),
	Fname varchar(255) not null,
	Lname varchar(255) not null,
	BirthDate date,
	Age as DATEDIFF(YEAR, BirthDate, GETDATE()),
	PhoneNumber varchar(255),
	Address varchar(255)
);

create table Referee(
	RefereeSsn varchar(255) Primary key,
	Fname varchar(255) not null,
	Lname varchar(255) not null,
	BirthDate date,
	Age as DATEDIFF(YEAR, BirthDate, GETDATE()),
	PhoneNumber varchar(255),
	Address varchar(255)
);

create table SuperVisor(
	SuperVisorSsn varchar(255) Primary key,
	Fname varchar(255)	not null,
	Lname varchar(255)	not null,
	BirthDate date,
	Age as DATEDIFF(YEAR, BirthDate, GETDATE()),
	PhoneNumber varchar(255),
	Address varchar(255)
);

create table Player(
	PlayerSsn varchar(255) Primary key,
	Fname varchar(255)	not null,
	Lname varchar(255)	not null,
	BirthDate date,
	Age as DATEDIFF(YEAR, BirthDate, GETDATE()),
	PhoneNumber varchar(255),
	Address varchar(255),
	Weight int,
	Height int
);

create table Event(
	EventID INT primary key,
	EventTime varchar(255)	not null,
	EventType varchar(255)	not null
);

create table PlayerInMatch(
	PlayerSsn varchar(255) references Player(PlayerSsn)
	on update cascade	on delete cascade,
	MatchID INT references Match(MatchID)
	on update cascade	on delete cascade,
	Position varchar(255),
	Fixed int,
	MatchRate INT
	Primary key (PlayerSsn, MatchID)
);

create table MatchEvents(
	PerformerPlayer varchar(255) references Player(PlayerSsn)
	on update cascade	on delete set null,
	InvolvedPlayer varchar(255) references Player(PlayerSsn)
	on update cascade	on delete set null,
	MatchID INT references Match(MatchID)
	on update cascade	on delete cascade,
	EventID int references Event(EventID)
	on update cascade	on delete cascade,
	Primary key (PerformerPlayer, InvolvedPlayer, MatchID, EventID)
);

Create table TechnicalStaffContract(
	PreviousTeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	DestinationTeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	TechnicalStaffSsn varchar(255) references TechnicalStaff(TechnicalStaffSsn)
	on update cascade	on delete cascade,
	Salary int not null,
	ContractDate date not null,
	ContractPeriod int not null,
	TerminationDate date
	Primary key (PreviousTeamID, DestinationTeamID, TechnicalStaffSsn)
);

create table PlayerContract(
	PreviousTeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	DestinationTeamID INT references Team(TeamID)
	on update cascade	on delete cascade,
	PlayerSsn varchar(255) references Player(PlayerSsn)
	on update cascade	on delete cascade,
	Salary int not null,
	ContractDate date not null,
	ContractPeriod int not null,
	TerminationDate date,
	ShirtNumber int
	Primary key (PreviousTeamID, DestinationTeamID, PlayerSsn)
);

create table RefreeTeam(
	RefereeSsn varchar(255) references Referee(RefereeSsn)
	on update cascade	on delete set null,
	MatchID int references Match(MatchID)
	on update cascade	on delete cascade,
	RefreeRole varchar(255),
	RefreeMatchReport varchar(255),
	RefreeMatchRate varchar(255),
	primary key(RefereeSsn, MatchID) 
);

create table SuperVisorTeam(
	SuperVisorSsn varchar(255) references SuperVisor(SuperVisorSsn)
	on update cascade	on delete set null,
	MatchID int references Match(MatchID)
	on update cascade	on delete cascade,
	SuperVisorRole varchar(255),
	SuperVisorReport varchar(255),
	primary key(SuperVisorSsn, MatchID)
);
