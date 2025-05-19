CREATE TABLE "accounts" (
	"id"	INTEGER,
	"username"	TEXT NOT NULL UNIQUE,
	"password"	TEXT NOT NULL,
	"ip"	TEXT NOT NULL,
	"serial"	TEXT NOT NULL,
	"admin"	INTEGER NOT NULL DEFAULT '0',
	"vip"	INTEGER NOT NULL DEFAULT '0',
	"isnew"	INTEGER NOT NULL DEFAULT '1',
	"isbanned"	INTEGER NOT NULL DEFAULT '0',
	"regdate"	INTEGER NOT NULL,
	"lastlogin"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "characters" (
	"id"	INTEGER,
	"owner"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL UNIQUE,
	"age"	INTEGER NOT NULL DEFAULT '0',
	"description"	TEXT NOT NULL,
	"skin"	INTEGER NOT NULL DEFAULT '0',
	"iszombie"	INTEGER NOT NULL DEFAULT '0',
	"health"	REAL NOT NULL DEFAULT '100.0',
	"maxhealth"	REAL NOT NULL DEFAULT '100.0',
	"hunger"	INTEGER NOT NULL DEFAULT '100',
	"maxhunger"	INTEGER NOT NULL DEFAULT 100,
	"thirst"	INTEGER NOT NULL DEFAULT '100',
	"maxthirst"	INTEGER NOT NULL DEFAULT 100,
	"disease"	INTEGER NOT NULL DEFAULT 100,
	"maxdisease"	INTEGER NOT NULL DEFAULT 100,
	"spawned"	INTEGER NOT NULL DEFAULT 0,
	"px"	REAL NOT NULL DEFAULT '2574.8706',
	"py"	REAL NOT NULL DEFAULT '1089.8154',
	"pz"	REAL NOT NULL DEFAULT '10.8203',
	"pa"	REAL NOT NULL DEFAULT '359.6421',
	"interior"	INTEGER NOT NULL DEFAULT '0',
	"virtualworld"	INTEGER NOT NULL DEFAULT '0',
	"level"	INTEGER NOT NULL DEFAULT '1',
	"perkpoints"	INTEGER NOT NULL DEFAULT '0',
	"strength"	INTEGER NOT NULL DEFAULT '0',
	"constitution"	INTEGER NOT NULL DEFAULT '0',
	"endurance"	INTEGER NOT NULL DEFAULT '0',
	"faction"	INTEGER NOT NULL DEFAULT '0',
	"factionrank"	INTEGER NOT NULL DEFAULT '0',
	"fuelcanamount"	INTEGER NOT NULL DEFAULT 0,
	"wepslot0"	INTEGER NOT NULL DEFAULT 0,
	"wepslot1"	INTEGER NOT NULL DEFAULT 0,
	"wepslot2"	INTEGER NOT NULL DEFAULT 0,
	"wepslot3"	INTEGER NOT NULL DEFAULT 0,
	"wepslot4"	INTEGER NOT NULL DEFAULT 0,
	"wepslot5"	INTEGER NOT NULL DEFAULT 0,
	"wepslot6"	INTEGER NOT NULL DEFAULT 0,
	"wepslot7"	INTEGER NOT NULL DEFAULT 0,
	"wepslot8"	INTEGER NOT NULL DEFAULT 0,
	"wepslot9"	INTEGER NOT NULL DEFAULT 0,
	"wepslot10"	INTEGER NOT NULL DEFAULT 0,
	"wepslot11"	INTEGER NOT NULL DEFAULT 0,
	"wepslot12"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "factions" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL UNIQUE,
	"creator"	TEXT NOT NULL,
	"rank0"	TEXT NOT NULL DEFAULT 'Rank1',
	"rank1"	TEXT NOT NULL DEFAULT 'Rank2',
	"rank2"	REAL NOT NULL DEFAULT 'Rank3',
	"rank3"	TEXT NOT NULL DEFAULT 'Rank4',
	"rank4"	TEXT NOT NULL DEFAULT 'Rank5',
	"rank5"	TEXT NOT NULL DEFAULT 'Rank6',
	"rank6"	TEXT NOT NULL DEFAULT 'Rank7',
	"rank7"	TEXT NOT NULL DEFAULT 'Rank8',
	"rank8"	TEXT NOT NULL DEFAULT 'Co-Leader',
	"rank9"	TEXT NOT NULL DEFAULT 'Leader',
	"money"	INTEGER NOT NULL DEFAULT 1000,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "interiors" (
	"id"	INTEGER,
	"name"	TEXT,
	"intworld"	INTEGER NOT NULL DEFAULT 0,
	"virworld"	INTEGER,
	"intworldexit"	INTEGER NOT NULL DEFAULT 0,
	"virworldexit"	INTEGER NOT NULL DEFAULT 0,
	"purchaseprice"	INTEGER NOT NULL DEFAULT 0,
	"interiortype"	INTEGER NOT NULL DEFAULT 3,
	"owner"	TEXT NOT NULL DEFAULT 'Vacant',
	"islocked"	INTEGER NOT NULL DEFAULT 0,
	"penterx1"	REAL,
	"pentery1"	REAL,
	"penterz1"	REAL,
	"penterx2"	REAL,
	"pentery2"	REAL,
	"penterz2"	REAL,
	"pentera"	REAL,
	"pexitx1"	REAL,
	"pexity1"	REAL,
	"pexitz1"	REAL,
	"pexitx2"	REAL,
	"pexity2"	REAL,
	"pexitz2"	REAL,
	"pexita"	REAL,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "scavareas" (
	"id"	INTEGER,
	"posx"	REAL,
	"posy"	REAL,
	"posz"	REAL,
	"interior"	INTEGER,
	"world"	INTEGER,
	"type"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "items" (
	"id"	INTEGER,
	"sname"	TEXT,
	"pname"	TEXT,
	"description"	TEXT,
	"category"	INTEGER DEFAULT -1,
	"healamount"	INTEGER DEFAULT -1,
	"wepid"	INTEGER DEFAULT -1,
	"ammoid"	INTEGER DEFAULT -1,
	"wepslot"	INTEGER DEFAULT -1,
	"isusable"	INTEGER DEFAULT 0,
	"maxresource"	INTEGER DEFAULT -1,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "loottable" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL,
	"chance0"	INTEGER NOT NULL DEFAULT 0,
	"chance1"	INTEGER NOT NULL DEFAULT 0,
	"chance2"	INTEGER NOT NULL DEFAULT 0,
	"chance3"	INTEGER NOT NULL DEFAULT 0,
	"chance4"	INTEGER NOT NULL DEFAULT 0,
	"chance5"	INTEGER NOT NULL DEFAULT 0,
	"chance6"	INTEGER NOT NULL DEFAULT 0,
	"chance7"	INTEGER NOT NULL DEFAULT 0,
	"chance8"	INTEGER NOT NULL DEFAULT 0,
	"chance9"	INTEGER NOT NULL DEFAULT 0,
	"chance10"	INTEGER NOT NULL DEFAULT 0,
	"chance11"	INTEGER NOT NULL DEFAULT 0,
	"chance12"	INTEGER NOT NULL DEFAULT 0,
	"chance13"	INTEGER NOT NULL DEFAULT 0,
	"chance14"	INTEGER NOT NULL DEFAULT 0,
	"chance15"	INTEGER NOT NULL DEFAULT 0,
	"chance16"	INTEGER NOT NULL DEFAULT 0,
	"chance17"	INTEGER NOT NULL DEFAULT 0,
	"chance18"	INTEGER NOT NULL DEFAULT 0,
	"chance19"	INTEGER NOT NULL DEFAULT 0,
	"chance20"	INTEGER NOT NULL DEFAULT 0,
	"chance21"	INTEGER NOT NULL DEFAULT 0,
	"chance22"	INTEGER NOT NULL DEFAULT 0,
	"chance23"	INTEGER NOT NULL DEFAULT 0,
	"chance24"	INTEGER NOT NULL DEFAULT 0,
	"chance25"	INTEGER NOT NULL DEFAULT 0,
	"chance26"	INTEGER NOT NULL DEFAULT 0,
	"chance27"	INTEGER NOT NULL DEFAULT 0,
	"chance28"	INTEGER NOT NULL DEFAULT 0,
	"chance29"	INTEGER NOT NULL DEFAULT 0,
	"chance30"	INTEGER NOT NULL DEFAULT 0,
	"chance31"	INTEGER NOT NULL DEFAULT 0,
	"chance32"	INTEGER NOT NULL DEFAULT 0,
	"chance33"	INTEGER NOT NULL DEFAULT 0,
	"chance34"	INTEGER NOT NULL DEFAULT 0,
	"chance35"	INTEGER NOT NULL DEFAULT 0,
	"chance36"	INTEGER NOT NULL DEFAULT 0,
	"chance37"	INTEGER NOT NULL DEFAULT 0,
	"chance38"	INTEGER NOT NULL DEFAULT 0,
	"chance39"	INTEGER NOT NULL DEFAULT 0,
	"chance40"	INTEGER NOT NULL DEFAULT 0,
	"chance41"	INTEGER NOT NULL DEFAULT 0,
	"chance42"	INTEGER NOT NULL DEFAULT 0,
	"chance43"	INTEGER NOT NULL DEFAULT 0,
	"chance44"	INTEGER NOT NULL DEFAULT 0,
	"chance45"	INTEGER NOT NULL DEFAULT 0,
	"chance46"	INTEGER NOT NULL DEFAULT 0,
	"chance47"	INTEGER NOT NULL DEFAULT 0,
	"chance48"	INTEGER NOT NULL DEFAULT 0,
	"chance49"	INTEGER NOT NULL DEFAULT 0,
	"chance50"	INTEGER NOT NULL DEFAULT 0,
	"chance51"	INTEGER NOT NULL DEFAULT 0,
	"chance52"	INTEGER NOT NULL DEFAULT 0,
	"chance53"	INTEGER NOT NULL DEFAULT 0,
	"chance54"	INTEGER NOT NULL DEFAULT 0,
	"chance55"	INTEGER NOT NULL DEFAULT 0,
	"chance56"	INTEGER NOT NULL DEFAULT 0,
	"chance57"	INTEGER NOT NULL DEFAULT 0,
	"chance58"	INTEGER NOT NULL DEFAULT 0,
	"chance59"	INTEGER NOT NULL DEFAULT 0,
	"chance60"	INTEGER NOT NULL DEFAULT 0,
	"chance61"	INTEGER NOT NULL DEFAULT 0,
	"chance62"	INTEGER NOT NULL DEFAULT 0,
	"chance63"	INTEGER NOT NULL DEFAULT 0,
	"chance64"	INTEGER NOT NULL DEFAULT 0,
	"chance65"	INTEGER NOT NULL DEFAULT 0,
	"chance66"	INTEGER NOT NULL DEFAULT 0,
	"chance67"	INTEGER NOT NULL DEFAULT 0,
	"chance68"	INTEGER NOT NULL DEFAULT 0,
	"chance69"	INTEGER NOT NULL DEFAULT 0,
	"chance70"	INTEGER NOT NULL DEFAULT 0,
	"chance71"	INTEGER NOT NULL DEFAULT 0,
	"chance72"	INTEGER NOT NULL DEFAULT 0,
	"chance73"	INTEGER NOT NULL DEFAULT 0,
	"chance74"	INTEGER NOT NULL DEFAULT 0,
	"chance75"	INTEGER NOT NULL DEFAULT 0,
	"chance76"	INTEGER NOT NULL DEFAULT 0,
	"chance77"	INTEGER NOT NULL DEFAULT 0,
	"chance78"	INTEGER NOT NULL DEFAULT 0,
	"chance79"	INTEGER NOT NULL DEFAULT 0,
	"chance80"	INTEGER NOT NULL DEFAULT 0,
	"chance81"	INTEGER NOT NULL DEFAULT 0,
	"chance82"	INTEGER NOT NULL DEFAULT 0,
	"chance83"	INTEGER NOT NULL DEFAULT 0,
	"chance84"	INTEGER NOT NULL DEFAULT 0,
	"chance85"	INTEGER NOT NULL DEFAULT 0,
	"chance86"	INTEGER NOT NULL DEFAULT 0,
	"chance87"	INTEGER NOT NULL DEFAULT 0,
	"chance88"	INTEGER NOT NULL DEFAULT 0,
	"chance89"	INTEGER NOT NULL DEFAULT 0,
	"chance90"	INTEGER NOT NULL DEFAULT 0,
	"chance91"	INTEGER NOT NULL DEFAULT 0,
	"chance92"	INTEGER NOT NULL DEFAULT 0,
	"chance93"	INTEGER NOT NULL DEFAULT 0,
	"chance94"	INTEGER NOT NULL DEFAULT 0,
	"chance95"	INTEGER NOT NULL DEFAULT 0,
	"chance96"	INTEGER NOT NULL DEFAULT 0,
	"chance97"	INTEGER NOT NULL DEFAULT 0,
	"chance98"	INTEGER NOT NULL DEFAULT 0,
	"chance99"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "inventory" (
	"id"	INTEGER,
	"character"	TEXT NOT NULL,
	"item1"	INTEGER NOT NULL DEFAULT 0,
	"item2"	INTEGER NOT NULL DEFAULT 0,
	"item3"	INTEGER NOT NULL DEFAULT 0,
	"item4"	INTEGER NOT NULL DEFAULT 0,
	"item5"	INTEGER NOT NULL DEFAULT 0,
	"item6"	INTEGER NOT NULL DEFAULT 0,
	"item7"	INTEGER NOT NULL DEFAULT 0,
	"item8"	INTEGER NOT NULL DEFAULT 0,
	"item9"	INTEGER NOT NULL DEFAULT 0,
	"item10"	INTEGER NOT NULL DEFAULT 0,
	"item11"	INTEGER NOT NULL DEFAULT 0,
	"item12"	INTEGER NOT NULL DEFAULT 0,
	"item13"	INTEGER NOT NULL DEFAULT 0,
	"item14"	INTEGER NOT NULL DEFAULT 0,
	"item15"	INTEGER NOT NULL DEFAULT 0,
	"item16"	INTEGER NOT NULL DEFAULT 0,
	"item17"	INTEGER NOT NULL DEFAULT 0,
	"item18"	INTEGER NOT NULL DEFAULT 0,
	"item19"	INTEGER NOT NULL DEFAULT 0,
	"item20"	INTEGER NOT NULL DEFAULT 0,
	"item21"	INTEGER NOT NULL DEFAULT 0,
	"item22"	INTEGER NOT NULL DEFAULT 0,
	"item23"	INTEGER NOT NULL DEFAULT 0,
	"item24"	INTEGER NOT NULL DEFAULT 0,
	"item25"	INTEGER NOT NULL DEFAULT 0,
	"item26"	INTEGER NOT NULL DEFAULT 0,
	"item27"	INTEGER NOT NULL DEFAULT 0,
	"item28"	INTEGER NOT NULL DEFAULT 0,
	"item29"	INTEGER NOT NULL DEFAULT 0,
	"item30"	INTEGER NOT NULL DEFAULT 0,
	"item31"	INTEGER NOT NULL DEFAULT 0,
	"item32"	INTEGER NOT NULL DEFAULT 0,
	"item33"	INTEGER NOT NULL DEFAULT 0,
	"item34"	INTEGER NOT NULL DEFAULT 0,
	"item35"	INTEGER NOT NULL DEFAULT 0,
	"item36"	INTEGER NOT NULL DEFAULT 0,
	"item37"	INTEGER NOT NULL DEFAULT 0,
	"item38"	INTEGER NOT NULL DEFAULT 0,
	"item39"	INTEGER NOT NULL DEFAULT 0,
	"item40"	INTEGER NOT NULL DEFAULT 0,
	"item41"	INTEGER NOT NULL DEFAULT 0,
	"item42"	INTEGER NOT NULL DEFAULT 0,
	"item43"	INTEGER NOT NULL DEFAULT 0,
	"item44"	INTEGER NOT NULL DEFAULT 0,
	"item45"	INTEGER NOT NULL DEFAULT 0,
	"item46"	INTEGER NOT NULL DEFAULT 0,
	"item47"	INTEGER NOT NULL DEFAULT 0,
	"item48"	INTEGER NOT NULL DEFAULT 0,
	"item49"	INTEGER NOT NULL DEFAULT 0,
	"item50"	INTEGER NOT NULL DEFAULT 0,
	"item51"	INTEGER NOT NULL DEFAULT 0,
	"item52"	INTEGER NOT NULL DEFAULT 0,
	"item53"	INTEGER NOT NULL DEFAULT 0,
	"item54"	INTEGER NOT NULL DEFAULT 0,
	"item55"	INTEGER NOT NULL DEFAULT 0,
	"item56"	INTEGER NOT NULL DEFAULT 0,
	"item57"	INTEGER NOT NULL DEFAULT 0,
	"item58"	INTEGER NOT NULL DEFAULT 0,
	"item59"	INTEGER NOT NULL DEFAULT 0,
	"item60"	INTEGER NOT NULL DEFAULT 0,
	"item61"	INTEGER NOT NULL DEFAULT 0,
	"item62"	INTEGER NOT NULL DEFAULT 0,
	"item63"	INTEGER NOT NULL DEFAULT 0,
	"item64"	INTEGER NOT NULL DEFAULT 0,
	"item65"	INTEGER NOT NULL DEFAULT 0,
	"item66"	INTEGER NOT NULL DEFAULT 0,
	"item67"	INTEGER NOT NULL DEFAULT 0,
	"item68"	INTEGER NOT NULL DEFAULT 0,
	"item69"	INTEGER NOT NULL DEFAULT 0,
	"item70"	INTEGER NOT NULL DEFAULT 0,
	"item71"	INTEGER NOT NULL DEFAULT 0,
	"item72"	INTEGER NOT NULL DEFAULT 0,
	"item73"	INTEGER NOT NULL DEFAULT 0,
	"item74"	INTEGER NOT NULL DEFAULT 0,
	"item75"	INTEGER NOT NULL DEFAULT 0,
	"item76"	INTEGER NOT NULL DEFAULT 0,
	"item77"	INTEGER NOT NULL DEFAULT 0,
	"item78"	INTEGER NOT NULL DEFAULT 0,
	"item79"	INTEGER NOT NULL DEFAULT 0,
	"item80"	INTEGER NOT NULL DEFAULT 0,
	"item81"	INTEGER NOT NULL DEFAULT 0,
	"item82"	INTEGER NOT NULL DEFAULT 0,
	"item83"	INTEGER NOT NULL DEFAULT 0,
	"item84"	INTEGER NOT NULL DEFAULT 0,
	"item85"	INTEGER NOT NULL DEFAULT 0,
	"item86"	INTEGER NOT NULL DEFAULT 0,
	"item87"	INTEGER NOT NULL DEFAULT 0,
	"item88"	INTEGER NOT NULL DEFAULT 0,
	"item89"	INTEGER NOT NULL DEFAULT 0,
	"item90"	INTEGER NOT NULL DEFAULT 0,
	"item91"	INTEGER NOT NULL DEFAULT 0,
	"item92"	INTEGER NOT NULL DEFAULT 0,
	"item93"	INTEGER NOT NULL DEFAULT 0,
	"item94"	INTEGER NOT NULL DEFAULT 0,
	"item95"	INTEGER NOT NULL DEFAULT 0,
	"item96"	INTEGER NOT NULL DEFAULT 0,
	"item97"	INTEGER NOT NULL DEFAULT 0,
	"item98"	INTEGER NOT NULL DEFAULT 0,
	"item99"	INTEGER NOT NULL DEFAULT 0,
	"item100"	INTEGER NOT NULL DEFAULT 0,
	"item101"	INTEGER NOT NULL DEFAULT 0,
	"item102"	INTEGER NOT NULL DEFAULT 0,
	"item103"	INTEGER NOT NULL DEFAULT 0,
	"item104"	INTEGER NOT NULL DEFAULT 0,
	"item105"	INTEGER NOT NULL DEFAULT 0,
	"item106"	INTEGER NOT NULL DEFAULT 0,
	"item107"	INTEGER NOT NULL DEFAULT 0,
	"item108"	INTEGER NOT NULL DEFAULT 0,
	"item109"	INTEGER NOT NULL DEFAULT 0,
	"item110"	INTEGER NOT NULL DEFAULT 0,
	"item111"	INTEGER NOT NULL DEFAULT 0,
	"item112"	INTEGER NOT NULL DEFAULT 0,
	"item113"	INTEGER NOT NULL DEFAULT 0,
	"item114"	INTEGER NOT NULL DEFAULT 0,
	"item115"	INTEGER NOT NULL DEFAULT 0,
	"item116"	INTEGER NOT NULL DEFAULT 0,
	"item117"	INTEGER NOT NULL DEFAULT 0,
	"item118"	INTEGER NOT NULL DEFAULT 0,
	"item119"	INTEGER NOT NULL DEFAULT 0,
	"item120"	INTEGER NOT NULL DEFAULT 0,
	"item121"	INTEGER NOT NULL DEFAULT 0,
	"item122"	INTEGER NOT NULL DEFAULT 0,
	"item123"	INTEGER NOT NULL DEFAULT 0,
	"item124"	INTEGER NOT NULL DEFAULT 0,
	"item125"	INTEGER NOT NULL DEFAULT 0,
	"item126"	INTEGER NOT NULL DEFAULT 0,
	"item127"	INTEGER NOT NULL DEFAULT 0,
	"item128"	INTEGER NOT NULL DEFAULT 0,
	"item129"	INTEGER NOT NULL DEFAULT 0,
	"item130"	INTEGER NOT NULL DEFAULT 0,
	"item131"	INTEGER NOT NULL DEFAULT 0,
	"item132"	INTEGER NOT NULL DEFAULT 0,
	"item133"	INTEGER NOT NULL DEFAULT 0,
	"item134"	INTEGER NOT NULL DEFAULT 0,
	"item135"	INTEGER NOT NULL DEFAULT 0,
	"item136"	INTEGER NOT NULL DEFAULT 0,
	"item137"	INTEGER NOT NULL DEFAULT 0,
	"item138"	INTEGER NOT NULL DEFAULT 0,
	"item139"	INTEGER NOT NULL DEFAULT 0,
	"item140"	INTEGER NOT NULL DEFAULT 0,
	"item141"	INTEGER NOT NULL DEFAULT 0,
	"item142"	INTEGER NOT NULL DEFAULT 0,
	"item143"	INTEGER NOT NULL DEFAULT 0,
	"item144"	INTEGER NOT NULL DEFAULT 0,
	"item145"	INTEGER NOT NULL DEFAULT 0,
	"item146"	INTEGER NOT NULL DEFAULT 0,
	"item147"	INTEGER NOT NULL DEFAULT 0,
	"item148"	INTEGER NOT NULL DEFAULT 0,
	"item149"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE "fuelpump" (
	"id"	INTEGER,
	"posx"	REAL NOT NULL,
	"posy"	REAL NOT NULL,
	"posz"	REAL NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);

/*Default items as per main server, which has ids that corrospond with the loottables included in this file*/
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (1, 'Scrap', 'Scrap', 'Some scrap metal. Might be useful for something.', 0, -1, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (2, 'Candy Bar', 'Candy Bars', 'It might be a bit out of date, but it will have to do for now.', 1, 5, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (3, 'Carton of Juice', 'Cartons of Juice', 'Freshly squeezed orange juice... or maybe it once was fresh.', 2, 5, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (4, 'Money', 'Monies', 'Useful to pay for things.', 0, -1, -1, -1, -1, 0, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (5, 'Baseball Bat', 'Baseball Bats', 'Normally used for baseball games... good for smashing heads in too.', 4, -1, 5, -1, 1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (6, '9mm Pistol', '9mm Pistols', 'A basic pistol which fires 9mm rounds.', 4, -1, 22, 7, 2, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (7, '9mm Round', '9mm Rounds', 'Rounds of ammo used for 9mm pistols, Uzi, and Tec-9 weapons.', 5, -1, -1, -1, -1, 0, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (8, 'Shotgun', 'Shotguns', 'Good at close range. Fires 12 gauge shells.', 4, -1, 25, 9, 3, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (9, '12 Gauge Shell', '12 Gauge Shells', 'Shells used with shotguns as ammo.', 5, -1, -1, -1, -1, 0, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (10, 'Bandage', 'Bandages', 'Used to stop bleeding from minor wounds.', 3, 5, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (11, 'Large Medical Kit', 'Large Medical Kits', 'A large medical kit full of all the supplies you might need for injuries.', 3, 100, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (12, 'Small Medical Kit', 'Small Medical Kits', 'A small medical kit with some basic medical supplies.', 3, 50, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (13, 'Medical Syringe', 'Medical Syringes', 'A syringe with some form of liquid medicine.', 3, 25, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (14, 'Paracetamol', 'Paracetamol', 'A small tablet that helps ease pain.', 3, 10, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (15, 'Uzi', 'Uzis', 'A submachine fun with a faster fire rate than a standard pistol while still using 9mm rounds.', 4, -1, 28, 7, 4, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (16, 'Shovel', 'Shovels', 'Good at digging things up... or burying them.', 4, -1, 6, -1, 1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (17, 'Desert Eagle', 'Desert Eagles', 'Uses .44 ammo, a heavier and more powerful handgun.', 4, -1, 24, 18, 2, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (18, '.44 Round', '.44 Rounds', 'Ammo used by the Desert Eagle.', 5, -1, -1, -1, -1, 0, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (19, 'Ration', 'Rations', 'A ration pack which greatly restores hunger.', 1, 50, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (20, 'Bottle of Water', 'Bottles of Water', 'Probably the most important liquid you could hope to find.', 2, 25, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (21, 'Chocolate Bar', 'Chocolate Bars', 'It might not be healthiest, but it is still tasty.', 1, 15, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (22, 'Biscuit', 'Biscuits', 'Very dry, but it staves off the hunger a little bit.', 1, 10, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (23, 'Canteen of Water', 'Canteens of Water', 'Bigger and heavier than a basic bottle of water, but also reusable!', 2, 45, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (24, 'Empty Canteen', 'Empty Canteens', 'Refillable canteen for liquid.', 0, -1, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (25, 'Canteen of Dirty Water', 'Canteens of Dirty Water', 'A canteen filled with dirty, unpurified water.', 2, 15, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (26, 'Purification Tablet', 'Purification Tablets', 'A purification tablet used to purify dirty water, making it safe to drink.', 0, -1, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (27, 'Antibiotic', 'Antibiotics', 'An antibiotic tablet used to cure disease.', 3, 10, -1, -1, -1, 1, -1);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (28, 'Fuel Can', 'Fuel Cans', 'Holds fuel for vehicles or generators.', 0, -1, -1, -1, -1, 1, 30);
INSERT INTO "main"."items" ("id", "sname", "pname", "description", "category", "healamount", "wepid", "ammoid", "wepslot", "isusable", "maxresource") VALUES (29, 'Nite Stick', 'Nite Sticks', 'A weapon normally used by the police in a more civilized time.', 4, -1, 3, -1, 1, 1, -1);

/*The default loottables as they are on the main server.*/
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (1, 'Scrap', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (2, 'Weapons and Ammo', 6, 7, 7, 8, 9, 7, 15, 17, 18, 5, 16, 6, 7, 8, 9, 7, 15, 17, 18, 5, 16, 15, 17, 18, 5, 16, 6, 7, 7, 8, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 29, 29, 29, 29, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (3, 'Body', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (4, 'Food and Drink', 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (5, 'Medical', 11, 10, 12, 13, 14, 10, 12, 13, 14, 10, 10, 12, 13, 14, 12, 10, 12, 13, 14, 13, 10, 12, 13, 14, 14, 10, 12, 13, 14, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (6, 'Money', 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO "main"."loottable" ("id", "name", "chance0", "chance1", "chance2", "chance3", "chance4", "chance5", "chance6", "chance7", "chance8", "chance9", "chance10", "chance11", "chance12", "chance13", "chance14", "chance15", "chance16", "chance17", "chance18", "chance19", "chance20", "chance21", "chance22", "chance23", "chance24", "chance25", "chance26", "chance27", "chance28", "chance29", "chance30", "chance31", "chance32", "chance33", "chance34", "chance35", "chance36", "chance37", "chance38", "chance39", "chance40", "chance41", "chance42", "chance43", "chance44", "chance45", "chance46", "chance47", "chance48", "chance49", "chance50", "chance51", "chance52", "chance53", "chance54", "chance55", "chance56", "chance57", "chance58", "chance59", "chance60", "chance61", "chance62", "chance63", "chance64", "chance65", "chance66", "chance67", "chance68", "chance69", "chance70", "chance71", "chance72", "chance73", "chance74", "chance75", "chance76", "chance77", "chance78", "chance79", "chance80", "chance81", "chance82", "chance83", "chance84", "chance85", "chance86", "chance87", "chance88", "chance89", "chance90", "chance91", "chance92", "chance93", "chance94", "chance95", "chance96", "chance97", "chance98", "chance99") VALUES (7, 'Gas Station', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

/*The default fuel pumps as they are on the main server*/
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (1, 2208.438476, 2470.369628, 10.99517);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (2, 2208.67749, 2474.711181, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (3, 2208.281738, 2480.42871, 10.99517);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (4, 2195.644775, 2480.277587, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (5, 2195.617919, 2474.613525, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (6, 2195.610839, 2470.104248, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (7, 2634.676513, 1112.564697, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (8, 2639.811035, 1112.758178, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (9, 2645.335205, 1112.81726, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (10, 2645.462646, 1110.857299, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (11, 2639.836425, 1110.876586, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (12, 2634.47998, 1110.708374, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (13, 2634.6875, 1101.994018, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (14, 2639.726562, 1101.920898, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (15, 2645.235595, 1101.902954, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (16, 2645.250976, 1099.890258, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (17, 2639.893554, 1099.875732, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (18, 2634.455566, 1099.988769, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (19, 2120.854248, 926.45288, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (20, 2115.039062, 926.633056, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (21, 2109.230468, 926.671142, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (22, 2109.007568, 924.515014, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (23, 2114.62915, 924.626403, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (24, 2121.010009, 924.587707, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (25, 2120.92163, 915.60614, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (26, 2114.90747, 915.669433, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (27, 2108.821289, 915.665405, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (28, 2109.200439, 913.658203, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (29, 2114.706298, 913.844116, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (30, 2120.578369, 913.81781, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (31, 602.939697, 1707.877197, 6.992187);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (32, 624.791137, 1676.98059, 6.992187);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (33, -1329.309936, 2668.228027, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (34, -1328.88623, 2670.287109, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (35, -1328.606079, 2673.767089, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (36, -1328.461059, 2675.619628, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (37, -1327.892944, 2679.300048, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (38, -1327.465209, 2681.079345, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (39, -1326.900024, 2684.731201, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (40, -1326.555664, 2686.50415, 50.0625);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (41, 1590.230834, 2205.430664, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (42, 1596.212158, 2205.271728, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (43, 1601.547119, 2205.499511, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (44, 1602.407226, 2203.728515, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (45, 1595.684936, 2203.622558, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (46, 1590.23645, 2203.609863, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (47, 1590.067138, 2194.521484, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (48, 1596.062744, 2194.426757, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (49, 1601.624267, 2194.454589, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (50, 1602.022827, 2192.865722, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (51, 1596.336547, 2192.719482, 10.820312);
INSERT INTO "main"."fuelpump" ("id", "posx", "posy", "posz") VALUES (52, 1590.561035, 2192.768798, 10.820312);
