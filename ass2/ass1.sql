-- Assignment 1 Stage 2
-- Schema for the et.org events/ticketing site
--
-- Written by <<YOUR NAME GOES HERE>>
--
-- Conventions:
-- - all entity table names are plural
-- - most entities have an artifical primary key called "id"
-- - foreign keys are named after the relationship they represent

-- Generally useful domains

create domain URLValue as
	varchar(100) check (value like 'http://%');

create domain EmailValue as
	varchar(100) check (value like '%@%.%');

create domain GenderValue as
	char(1) check (value in ('m','f','n'));

create domain ColourValue as
	char(7) check (value ~ '#[0-9A-Fa-f]{6}');

create domain LocationValue as varchar(40)
	check (value ~ E'^-?\\d+\.\\d+,-?\\d+\.\\d+$');
	-- latitiude and longitude in format used by Google Maps
	-- e.g. '-33.916369,151.23024' (UNSW)

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);


-- PLACES: addresses, geographic locations, etc.

create table Places (
	id          serial, -- integer default nextval('some_seq_or_other')
	name 		NameValue	not null,
	address    	varchar unique,
	city		varchar,
	state       varchar,
	country    varchar(50) not null,
	postalcode  integer,
	gpscoords	LocationValue , ------------------------bug
	billingAddress  varchar,
	homeAddress varchar,
	creater_user integer,
	primary key (id,creater_user,name)
);




-- PEOPLE: information about various kinds of people
-- Users are People who can login to the system
-- Contacts are people about whom we have minimal info
-- Organisers are "entities" who organise Events

create table People (
	id          serial,
	email 		EmailValue	not null,
	givenname 		NameValue	not null,
	familyname		NameValue,
	primary key (id)
);
--------------------------------single sub class ,show the samll class hierarchy
create table Users (
	id serial,
	gender GenderValue,
	birthday date,
	phone integer,
	blog URLValue,
	website URLValue,
	password varchar not null,
	showName varchar,
	billingAddress varchar not null,
	homeAddress	varchar ,
	primary key (id)
);

create table Organisers (
	id   serial,
	create_user integer not null,  
	name LongNameValue	not null,
	logo bytea,
	about varchar,
	theme serial not null, 
	primary key (id)
);

-- PAGEs: settings for pages in et.org

create table PageColours (
	id      serial,
	owner	integer ,
	maintext varchar,
	heading varchar,
	headtext	varchar,
	borders	varchar,
	boxes	varchar,
	links	URLValue,
	background	varchar,
	isTemplate	boolean default false,
	name  NameValue,
	primary key (id)
);

----------------------------------------- peoople

create table ContactLists (
	id serial,
	name NameValue not null,
	people integer,
	nickName varchar,
	owner_user  serial not null,
	primary key (id)
);


-- EVENTS: things that happen and which people attend via tickets
create domain event_cat as varchar
	check (value in ('music','food/wine','theatre','featival'));

create table EventInfo (
	id          serial,
	showFee  	boolean not null,
	showLeft 	boolean	not null,
	isPrivate	boolean	not null ,
	title 	varchar(100) not null unique,
	details	varchar 	not null ,
	categories	event_cat,
	starting_Time	timestamp,
	duration	interval not null,
	location LocationValue,
	event_organiser integer not null,
	primary key (id)
);

create table Events (
	id          serial,
	event_info  integer not null,  
	startDate	date not null,
	startTime   time not null,
	endTime		time,
	endDate		date,
	primary key (id)
);

create domain EventRepetitionType as varchar(10)
	check (value in ('daily','weekly','monthly-by-day','monthly-by-date'));

create domain DayOfWeekType as char(3)
	check (value in ('mon','tue','wed','thu','fri','sat','sun'));

create table RepeatingEvents (
	id          serial,
	lowerDate	date not null,
	upperDate	date not null check(upperDate > lowerDate),
	event_id 	integer,
	repeat_time EventRepetitionType not null,
	primary key (id)
);


-- TICKETS: things that let you attend an event
create domain tK_Type as varchar
	check (value in ('First Class', 'Standard', 'Mosh Pit'));
create table TicketTypes (
	id          serial unique,
	event_id 	serial not null,
	TICK_type 	tK_Type,
	description	 varchar(100),
	totalnumber  integer not null,
	numberleft integer,
	max_per_sale integer not null,
	currency integer,
	price money,
	primary key (id,event_id,tick_type)
);

create table SoldTickets(
	id serial,
	event_id integer not null,
	quantity integer not null,
	ticket_type integer not null,
	purchaser  serial not null,
	url_for_pur URLValue not null ,
	primary key (id)
);

------ place
alter table Places add constraint place_user foreign key(creater_user) references Users(id);
--user
alter table Users add constraint user_people foreign key(id) references People(id);
--orgainser
alter table Organisers add constraint organ_user foreign key (create_user) references Users(id);
alter table Organisers add constraint organ_pagecolor foreign key (theme) references PageColours(id);
---pagecolor
alter table PageColours add constraint pagecolor_user	foreign key (owner) references Users(id); ----the relationship between user and pagecolours
------contactlist
alter table ContactLists add constraint	concat_people foreign key (people) references People(id);
alter table ContactLists add constraint	concat_user foreign key(owner_user) references Users(id);
------eventinfo
alter table EventInfo add constraint	eventinfo_place foreign key (location) references Places(address);
alter table EventInfo add constraint	eventinfo_organiser	foreign key (event_organiser) references Organisers(id);
--------event
alter table Events add constraint event_info	foreign key (event_info) references EventInfo(id);
--------reptveent
alter table RepeatingEvents add constraint rept_event foreign key (event_id) references Events(id);
-----ticker
alter table TicketTypes add constraint ticket_event	foreign key (event_id) references EventInfo(id);
----sold tick
alter table SoldTickets add constraint sold_people	foreign key (purchaser) references People(id);
alter table SoldTickets add constraint sold_event   foreign key (event_id) references Events(id);
alter table SoldTickets add constraint sold_tick   foreign key (ticket_type) references TicketTypes(id);




-------- input people
insert into  people(email,givenname) values ('1@mail.','a'),('2@mail.','a1'),('3@mail.','a3'),('4@mail.','a4'),('5@mail.','a5');

-------- insert user
insert into users (id,password,billingAddress)
values (1,'avc','c1'),(2,'avc','c2'),(3,'avc','c3'),(4,'avc','c4');

-------- insert theme
insert into PageColours(owner,heading) values(1,'white'),(2,'black'),(3,'light');

--------- insert organiser
insert into Organisers(create_user,name,theme) values(1,'first',1),(1,'second',2),(2,'second',2),(3,'third',3);

---------- places
insert into Places(name,address,country,creater_user) 
values('home','gaungzhou','china',1) ,
('home','hangzhou','china',2),
('home','huizhou','china',3);

---------- insert event_info
insert into EventInfo (showFee,showLeft,isPrivate,title,details,duration,event_organiser)values (True,True,True,'sleep','slllllll','00:40',1),
(True,True,True,'walk','sllllllasd','10:40',2),
(True,True,True,'run','slladsfl','02:40',2),
(True,True,True,'singing','slsdflllll','01:40',3);

---------- insert event
insert into Events(Event_Info,startDate,startTime)
values (1,'2020-01-04','07:40'),
(2,'2020-01-01','07:40'),
(2,'2020-01-08','07:40'),
(2,'2020-01-15','07:40'),
(3,'2020-01-01','07:40'),
(1,'2020-01-05','07:40'),
(1,'2020-01-06','07:40'),
(1,'2020-01-07','07:40'),
(1,'2020-01-08','07:40'),
(1,'2020-01-09','07:40');

---------- repeat event
insert into RepeatingEvents (lowerDate,upperDate,repeat_time)
values ('2020-01-04','2020-01-09','daily');

-------ticket
insert into TicketTypes (event_id,tick_type,totalnumber,max_per_sale)
values (1,'Standard',200,2),
(2,'Standard',100,2),
(3,'First Class',300,5),
(4,'Standard',600,20);

-----soldtick
insert into SoldTickets(event_id,quantity,ticket_type,purchaser,url_for_pur)
values (1,1,1,5,'http://adfasd'),
(1,2,1,2,'http://adsfadfasdadsf'),
(2,1,2,1,'http://adfasdadsf'),
(4,3,4,2,'http://adfasdads'),
(3,1,3,4,'http://adfasdadfads');