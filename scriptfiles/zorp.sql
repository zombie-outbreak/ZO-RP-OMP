-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 04, 2025 at 12:55 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `zorp`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `username` varchar(24) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `email_verified` tinyint(4) NOT NULL DEFAULT 0,
  `verification_code` varchar(10) DEFAULT NULL,
  `verification_expires` int(11) DEFAULT NULL,
  `ip` varchar(16) NOT NULL,
  `serial` varchar(255) NOT NULL,
  `admin` tinyint(4) NOT NULL DEFAULT 0,
  `helper` tinyint(4) NOT NULL DEFAULT 0,
  `vip` tinyint(4) NOT NULL DEFAULT 0,
  `isnew` tinyint(4) NOT NULL DEFAULT 1,
  `isbanned` tinyint(4) NOT NULL DEFAULT 0,
  `regdate` int(11) NOT NULL,
  `lastlogin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`id`, `username`, `password`, `email`, `email_verified`, `verification_code`, `verification_expires`, `ip`, `serial`, `admin`, `helper`, `vip`, `isnew`, `isbanned`, `regdate`, `lastlogin`) VALUES
(1, 'Test', '$2b$12$IPgM2BAp89gWaWjJXzzojexVIdufACxZyF1M2Ygp626BEI25e/U3m', 'null@nomail.com', 1, NULL, NULL, '127.0.0.1', 'NA', 5, 0, 0, 0, 0, 1761993954, 1762254127); -- password is: lolpass

-- --------------------------------------------------------

--
-- Table structure for table `admin_logs`
--

CREATE TABLE `admin_logs` (
  `id` int(11) NOT NULL,
  `admin_account_id` int(11) NOT NULL,
  `admin_username` varchar(24) NOT NULL,
  `admin_character_name` varchar(24) DEFAULT NULL,
  `admin_level` tinyint(4) NOT NULL,
  `command` varchar(64) NOT NULL,
  `params` varchar(255) DEFAULT NULL,
  `target_playerid` int(11) DEFAULT NULL,
  `target_username` varchar(24) DEFAULT NULL,
  `target_character_name` varchar(24) DEFAULT NULL,
  `ip_address` varchar(16) NOT NULL,
  `timestamp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE `characters` (
  `id` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `name` varchar(24) NOT NULL,
  `age` tinyint(4) NOT NULL DEFAULT 0,
  `description` text NOT NULL,
  `skin` smallint(6) NOT NULL DEFAULT 0,
  `iszombie` tinyint(4) NOT NULL DEFAULT 0,
  `health` float NOT NULL DEFAULT 100,
  `maxhealth` float NOT NULL DEFAULT 100,
  `hunger` smallint(6) NOT NULL DEFAULT 100,
  `maxhunger` smallint(6) NOT NULL DEFAULT 100,
  `thirst` smallint(6) NOT NULL DEFAULT 100,
  `maxthirst` smallint(6) NOT NULL DEFAULT 100,
  `disease` smallint(6) NOT NULL DEFAULT 100,
  `maxdisease` smallint(6) NOT NULL DEFAULT 100,
  `spawned` tinyint(4) NOT NULL DEFAULT 0,
  `px` float NOT NULL DEFAULT 2574.87,
  `py` float NOT NULL DEFAULT 1089.82,
  `pz` float NOT NULL DEFAULT 10.8203,
  `pa` float NOT NULL DEFAULT 359.642,
  `interior` int(11) NOT NULL DEFAULT 0,
  `virtualworld` int(11) NOT NULL DEFAULT 0,
  `level` smallint(6) NOT NULL DEFAULT 1,
  `exp` int(11) NOT NULL DEFAULT 0,
  `perkpoints` smallint(6) NOT NULL DEFAULT 0,
  `fuelcanamount` smallint(6) NOT NULL DEFAULT 0,
  `wepslot0` smallint(6) NOT NULL DEFAULT 0,
  `wepslot1` smallint(6) NOT NULL DEFAULT 0,
  `wepslot2` smallint(6) NOT NULL DEFAULT 0,
  `wepslot3` smallint(6) NOT NULL DEFAULT 0,
  `wepslot4` smallint(6) NOT NULL DEFAULT 0,
  `wepslot5` smallint(6) NOT NULL DEFAULT 0,
  `wepslot6` smallint(6) NOT NULL DEFAULT 0,
  `wepslot7` smallint(6) NOT NULL DEFAULT 0,
  `wepslot8` smallint(6) NOT NULL DEFAULT 0,
  `wepslot9` smallint(6) NOT NULL DEFAULT 0,
  `wepslot10` smallint(6) NOT NULL DEFAULT 0,
  `wepslot11` smallint(6) NOT NULL DEFAULT 0,
  `wepslot12` smallint(6) NOT NULL DEFAULT 0,
  `tinkererskilllevel` tinyint(4) NOT NULL DEFAULT 0,
  `mechanicskilllevel` tinyint(4) NOT NULL DEFAULT 0,
  `medicskilllevel` tinyint(4) NOT NULL DEFAULT 0,
  `gourmetskilllevel` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedjump` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedunarmed` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedbite` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedcombust` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedstun` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedgrab` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedbstr` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedsjump` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedcorn` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedhpinc` tinyint(4) NOT NULL DEFAULT 0,
  `unlockedhunt` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crafting_recipes`
--

CREATE TABLE `crafting_recipes` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `description` varchar(128) DEFAULT NULL,
  `input_item1` int(11) DEFAULT -1,
  `input_qty1` int(11) DEFAULT 0,
  `input_item2` int(11) DEFAULT -1,
  `input_qty2` int(11) DEFAULT 0,
  `input_item3` int(11) DEFAULT -1,
  `input_qty3` int(11) DEFAULT 0,
  `input_item4` int(11) DEFAULT -1,
  `input_qty4` int(11) DEFAULT 0,
  `input_item5` int(11) DEFAULT -1,
  `input_qty5` int(11) DEFAULT 0,
  `output_item` int(11) NOT NULL,
  `output_qty` int(11) DEFAULT 1,
  `skill_required` int(11) DEFAULT 0,
  `craft_time` int(11) DEFAULT 3000,
  `category` int(11) DEFAULT 0,
  `active` tinyint(4) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crafting_recipes`
--

INSERT INTO `crafting_recipes` (`id`, `name`, `description`, `input_item1`, `input_qty1`, `input_item2`, `input_qty2`, `input_item3`, `input_qty3`, `input_item4`, `input_qty4`, `input_item5`, `input_qty5`, `output_item`, `output_qty`, `skill_required`, `craft_time`, `category`, `active`) VALUES
(1, 'Bandage', 'Basic medical item for healing wounds', 30, 10, -1, 0, -1, 0, -1, 0, -1, 0, 10, 1, 0, 5000, 0, 1),
(2, 'Empty Canteen', 'A canteen to store liquids in', 1, 50, -1, 0, -1, 0, -1, 0, -1, 0, 24, 1, 1, 8000, 1, 1),
(3, 'Small Medical Kit', 'Advanced medical supplies', 10, 2, 14, 2, 13, 1, -1, 0, -1, 0, 12, 1, 2, 10000, 0, 1),
(4, 'Rations', 'A pack of basic rations', 2, 5, 3, 5, -1, 0, -1, 0, -1, 0, 19, 1, 1, 6000, 1, 1),
(5, 'Large Medical Kit', 'Comprehensive medical supplies', 12, 2, 10, 3, 13, 2, 14, 2, -1, 0, 11, 1, 3, 15000, 0, 1),
(6, 'Baseball Bat', 'Improvised melee weapon', 1, 30, 48, 1, -1, 0, -1, 0, -1, 0, 5, 1, 1, 7000, 1, 1),
(7, 'Nite Stick', 'Police baton weapon', 1, 25, 48, 1, -1, 0, -1, 0, -1, 0, 29, 1, 1, 6000, 1, 1),
(8, 'Knife', 'Sharp melee weapon', 1, 15, -1, 0, -1, 0, -1, 0, -1, 0, 31, 1, 0, 4000, 1, 1),
(9, 'Shovel', 'Digging tool and weapon', 1, 40, -1, 0, -1, 0, -1, 0, -1, 0, 16, 1, 1, 8000, 1, 1),
(10, 'Canteen of Water', 'Fill canteen with clean water', 24, 1, 20, 1, -1, 0, -1, 0, -1, 0, 23, 1, 0, 2000, 1, 1),
(11, 'Chainsaw', 'Powerful close-range weapon', 1, 100, 28, 1, 49, 2, -1, 0, -1, 0, 32, 1, 5, 20000, 1, 1),
(12, 'Toolbox', 'Assemble basic tools', 1, 80, 48, 2, 49, 1, -1, 0, -1, 0, 53, 1, 2, 12000, 1, 1),
(13, 'Backpack', 'Craft storage equipment', 30, 50, 48, 3, -1, 0, -1, 0, -1, 0, 52, 1, 1, 10000, 1, 1),
(14, 'Rope', 'Craft rope from cloth', 30, 30, -1, 0, -1, 0, -1, 0, -1, 0, 48, 1, 0, 5000, 1, 1),
(15, 'Sleeping Bag', 'Portable sleeping gear', 30, 40, 48, 2, -1, 0, -1, 0, -1, 0, 58, 1, 1, 9000, 1, 1),
(16, 'Tent', 'Shelter from elements', 30, 80, 48, 4, 1, 50, -1, 0, -1, 0, 59, 1, 2, 15000, 1, 1),
(17, 'Flashlight', 'Light source device', 1, 20, 47, 2, -1, 0, -1, 0, -1, 0, 46, 1, 1, 6000, 1, 1),
(18, 'Body Armor', 'Protective vest', 30, 100, 1, 80, -1, 0, -1, 0, -1, 0, 57, 1, 3, 18000, 1, 1),
(19, 'Gas Mask', 'Protective breathing equipment', 30, 60, 1, 40, -1, 0, -1, 0, -1, 0, 56, 1, 2, 12000, 1, 1),
(20, 'Fuel Can', 'Container for fuel', 1, 60, -1, 0, -1, 0, -1, 0, -1, 0, 28, 1, 1, 8000, 1, 1),
(21, 'Medical Syringe', 'Injectable medicine', 10, 1, 14, 3, -1, 0, -1, 0, -1, 0, 13, 2, 1, 7000, 0, 1),
(22, 'Radio', 'Communication device', 1, 70, 47, 4, -1, 0, -1, 0, -1, 0, 55, 1, 2, 13000, 1, 1),
(23, 'Binoculars', 'Viewing equipment', 1, 30, -1, 0, -1, 0, -1, 0, -1, 0, 54, 1, 1, 7000, 1, 1),
(24, 'Compass', 'Navigation tool', 1, 15, -1, 0, -1, 0, -1, 0, -1, 0, 60, 1, 0, 4000, 1, 1),
(25, 'MRE', 'Military ration pack', 2, 10, 3, 10, 22, 5, -1, 0, -1, 0, 45, 1, 2, 10000, 1, 1),
(26, 'Canned Beans', 'Preserve food in can', 2, 8, 1, 5, -1, 0, -1, 0, -1, 0, 41, 1, 1, 6000, 1, 1),
(27, 'Canned Soup', 'Prepare canned soup', 2, 10, 3, 5, 1, 3, -1, 0, -1, 0, 42, 1, 1, 7000, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `character_recipes`
--

CREATE TABLE `character_recipes` (
  `id` int(11) NOT NULL,
  `character_name` varchar(24) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `unlocked_date` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `factions`
--

CREATE TABLE `factions` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `tag` varchar(6) NOT NULL,
  `leader` varchar(24) NOT NULL,
  `color` int(11) NOT NULL DEFAULT -1,
  `created_date` int(11) NOT NULL,
  `motd` varchar(128) DEFAULT NULL,
  `bank_balance` int(11) NOT NULL DEFAULT 0,
  `level` smallint(6) NOT NULL DEFAULT 1,
  `base_interior_id` int(11) DEFAULT -1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faction_members`
--

CREATE TABLE `faction_members` (
  `id` int(11) NOT NULL,
  `faction_id` int(11) NOT NULL,
  `character_name` varchar(24) NOT NULL,
  `rank` smallint(6) NOT NULL DEFAULT 0,
  `joined_date` int(11) NOT NULL,
  `contribution` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faction_ranks`
--

CREATE TABLE `faction_ranks` (
  `id` int(11) NOT NULL,
  `faction_id` int(11) NOT NULL,
  `rank_id` smallint(6) NOT NULL,
  `rank_name` varchar(32) NOT NULL,
  `can_invite` tinyint(4) NOT NULL DEFAULT 0,
  `can_kick` tinyint(4) NOT NULL DEFAULT 0,
  `can_promote` tinyint(4) NOT NULL DEFAULT 0,
  `can_demote` tinyint(4) NOT NULL DEFAULT 0,
  `can_withdraw` tinyint(4) NOT NULL DEFAULT 0,
  `can_edit_ranks` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faction_territories`
--

CREATE TABLE `faction_territories` (
  `id` int(11) NOT NULL,
  `faction_id` int(11) NOT NULL,
  `zone_name` varchar(64) NOT NULL,
  `min_x` float NOT NULL,
  `min_y` float NOT NULL,
  `max_x` float NOT NULL,
  `max_y` float NOT NULL,
  `captured_date` int(11) NOT NULL,
  `capture_points` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `faction_territories`
--

INSERT INTO `faction_territories` (`id`, `faction_id`, `zone_name`, `min_x`, `min_y`, `max_x`, `max_y`, `captured_date`, `capture_points`) VALUES
(1, -1, 'Clown\'s Pocket', 2129, 1782.5, 2285, 1882.5, 1762201909, 0),
(2, -1, 'Emerald Isle', 2033, 2351.5, 2202, 2451.5, 1762196138, 0),
(3, -1, 'K.A.C.C', 2488, 2645.5, 2759, 2862.5, 1762196170, 0),
(4, -1, 'Four Dragons Casino', 1844, 923.5, 2046, 1088.5, 1762196373, 0);

-- --------------------------------------------------------

--
-- Table structure for table `fuelpump`
--

CREATE TABLE `fuelpump` (
  `id` int(11) NOT NULL,
  `posx` float NOT NULL,
  `posy` float NOT NULL,
  `posz` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `fuelpump`
--

INSERT INTO `fuelpump` (`id`, `posx`, `posy`, `posz`) VALUES
(1, 2208.44, 2470.37, 10.9952),
(2, 2208.68, 2474.71, 10.8203),
(3, 2208.28, 2480.43, 10.9952),
(4, 2195.64, 2480.28, 10.8203),
(5, 2195.62, 2474.61, 10.8203),
(6, 2195.61, 2470.1, 10.8203),
(7, 2634.68, 1112.56, 10.8203),
(8, 2639.81, 1112.76, 10.8203),
(9, 2645.34, 1112.82, 10.8203),
(10, 2645.46, 1110.86, 10.8203),
(11, 2639.84, 1110.88, 10.8203),
(12, 2634.48, 1110.71, 10.8203),
(13, 2634.69, 1101.99, 10.8203),
(14, 2639.73, 1101.92, 10.8203),
(15, 2645.24, 1101.9, 10.8203),
(16, 2645.25, 1099.89, 10.8203),
(17, 2639.89, 1099.88, 10.8203),
(18, 2634.46, 1099.99, 10.8203),
(19, 2120.85, 926.453, 10.8203),
(20, 2115.04, 926.633, 10.8203),
(21, 2109.23, 926.671, 10.8203),
(22, 2109.01, 924.515, 10.8203),
(23, 2114.63, 924.626, 10.8203),
(24, 2121.01, 924.588, 10.8203),
(25, 2120.92, 915.606, 10.8203),
(26, 2114.91, 915.669, 10.8203),
(27, 2108.82, 915.665, 10.8203),
(28, 2109.2, 913.658, 10.8203),
(29, 2114.71, 913.844, 10.8203),
(30, 2120.58, 913.818, 10.8203),
(31, 602.94, 1707.88, 6.99219),
(32, 624.791, 1676.98, 6.99219),
(33, -1329.31, 2668.23, 50.0625),
(34, -1328.89, 2670.29, 50.0625),
(35, -1328.61, 2673.77, 50.0625),
(36, -1328.46, 2675.62, 50.0625),
(37, -1327.89, 2679.3, 50.0625),
(38, -1327.47, 2681.08, 50.0625),
(39, -1326.9, 2684.73, 50.0625),
(40, -1326.56, 2686.5, 50.0625),
(41, 1590.23, 2205.43, 10.8203),
(42, 1596.21, 2205.27, 10.8203),
(43, 1601.55, 2205.5, 10.8203),
(44, 1602.41, 2203.73, 10.8203),
(45, 1595.68, 2203.62, 10.8203),
(46, 1590.24, 2203.61, 10.8203),
(47, 1590.07, 2194.52, 10.8203),
(48, 1596.06, 2194.43, 10.8203),
(49, 1601.62, 2194.45, 10.8203),
(50, 1602.02, 2192.87, 10.8203),
(51, 1596.34, 2192.72, 10.8203),
(52, 1590.56, 2192.77, 10.8203);

-- --------------------------------------------------------

--
-- Table structure for table `interiors`
--

CREATE TABLE `interiors` (
  `id` int(11) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `intworld` int(11) NOT NULL DEFAULT 0,
  `virworld` int(11) DEFAULT NULL,
  `intworldexit` int(11) NOT NULL DEFAULT 0,
  `virworldexit` int(11) NOT NULL DEFAULT 0,
  `purchaseprice` int(11) NOT NULL DEFAULT 0,
  `interiortype` tinyint(4) NOT NULL DEFAULT 3,
  `owner` varchar(24) NOT NULL DEFAULT 'Vacant',
  `islocked` tinyint(4) NOT NULL DEFAULT 0,
  `penterx1` float DEFAULT NULL,
  `pentery1` float DEFAULT NULL,
  `penterz1` float DEFAULT NULL,
  `penterx2` float DEFAULT NULL,
  `pentery2` float DEFAULT NULL,
  `penterz2` float DEFAULT NULL,
  `pentera` float DEFAULT NULL,
  `pexitx1` float DEFAULT NULL,
  `pexity1` float DEFAULT NULL,
  `pexitz1` float DEFAULT NULL,
  `pexitx2` float DEFAULT NULL,
  `pexity2` float DEFAULT NULL,
  `pexitz2` float DEFAULT NULL,
  `pexita` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `character` varchar(24) NOT NULL,
  `item1` smallint(6) NOT NULL DEFAULT 0,
  `item2` smallint(6) NOT NULL DEFAULT 0,
  `item3` smallint(6) NOT NULL DEFAULT 0,
  `item4` smallint(6) NOT NULL DEFAULT 0,
  `item5` smallint(6) NOT NULL DEFAULT 0,
  `item6` smallint(6) NOT NULL DEFAULT 0,
  `item7` smallint(6) NOT NULL DEFAULT 0,
  `item8` smallint(6) NOT NULL DEFAULT 0,
  `item9` smallint(6) NOT NULL DEFAULT 0,
  `item10` smallint(6) NOT NULL DEFAULT 0,
  `item11` smallint(6) NOT NULL DEFAULT 0,
  `item12` smallint(6) NOT NULL DEFAULT 0,
  `item13` smallint(6) NOT NULL DEFAULT 0,
  `item14` smallint(6) NOT NULL DEFAULT 0,
  `item15` smallint(6) NOT NULL DEFAULT 0,
  `item16` smallint(6) NOT NULL DEFAULT 0,
  `item17` smallint(6) NOT NULL DEFAULT 0,
  `item18` smallint(6) NOT NULL DEFAULT 0,
  `item19` smallint(6) NOT NULL DEFAULT 0,
  `item20` smallint(6) NOT NULL DEFAULT 0,
  `item21` smallint(6) NOT NULL DEFAULT 0,
  `item22` smallint(6) NOT NULL DEFAULT 0,
  `item23` smallint(6) NOT NULL DEFAULT 0,
  `item24` smallint(6) NOT NULL DEFAULT 0,
  `item25` smallint(6) NOT NULL DEFAULT 0,
  `item26` smallint(6) NOT NULL DEFAULT 0,
  `item27` smallint(6) NOT NULL DEFAULT 0,
  `item28` smallint(6) NOT NULL DEFAULT 0,
  `item29` smallint(6) NOT NULL DEFAULT 0,
  `item30` smallint(6) NOT NULL DEFAULT 0,
  `item31` smallint(6) NOT NULL DEFAULT 0,
  `item32` smallint(6) NOT NULL DEFAULT 0,
  `item33` smallint(6) NOT NULL DEFAULT 0,
  `item34` smallint(6) NOT NULL DEFAULT 0,
  `item35` smallint(6) NOT NULL DEFAULT 0,
  `item36` smallint(6) NOT NULL DEFAULT 0,
  `item37` smallint(6) NOT NULL DEFAULT 0,
  `item38` smallint(6) NOT NULL DEFAULT 0,
  `item39` smallint(6) NOT NULL DEFAULT 0,
  `item40` smallint(6) NOT NULL DEFAULT 0,
  `item41` smallint(6) NOT NULL DEFAULT 0,
  `item42` smallint(6) NOT NULL DEFAULT 0,
  `item43` smallint(6) NOT NULL DEFAULT 0,
  `item44` smallint(6) NOT NULL DEFAULT 0,
  `item45` smallint(6) NOT NULL DEFAULT 0,
  `item46` smallint(6) NOT NULL DEFAULT 0,
  `item47` smallint(6) NOT NULL DEFAULT 0,
  `item48` smallint(6) NOT NULL DEFAULT 0,
  `item49` smallint(6) NOT NULL DEFAULT 0,
  `item50` smallint(6) NOT NULL DEFAULT 0,
  `item51` smallint(6) NOT NULL DEFAULT 0,
  `item52` smallint(6) NOT NULL DEFAULT 0,
  `item53` smallint(6) NOT NULL DEFAULT 0,
  `item54` smallint(6) NOT NULL DEFAULT 0,
  `item55` smallint(6) NOT NULL DEFAULT 0,
  `item56` smallint(6) NOT NULL DEFAULT 0,
  `item57` smallint(6) NOT NULL DEFAULT 0,
  `item58` smallint(6) NOT NULL DEFAULT 0,
  `item59` smallint(6) NOT NULL DEFAULT 0,
  `item60` smallint(6) NOT NULL DEFAULT 0,
  `item61` smallint(6) NOT NULL DEFAULT 0,
  `item62` smallint(6) NOT NULL DEFAULT 0,
  `item63` smallint(6) NOT NULL DEFAULT 0,
  `item64` smallint(6) NOT NULL DEFAULT 0,
  `item65` smallint(6) NOT NULL DEFAULT 0,
  `item66` smallint(6) NOT NULL DEFAULT 0,
  `item67` smallint(6) NOT NULL DEFAULT 0,
  `item68` smallint(6) NOT NULL DEFAULT 0,
  `item69` smallint(6) NOT NULL DEFAULT 0,
  `item70` smallint(6) NOT NULL DEFAULT 0,
  `item71` smallint(6) NOT NULL DEFAULT 0,
  `item72` smallint(6) NOT NULL DEFAULT 0,
  `item73` smallint(6) NOT NULL DEFAULT 0,
  `item74` smallint(6) NOT NULL DEFAULT 0,
  `item75` smallint(6) NOT NULL DEFAULT 0,
  `item76` smallint(6) NOT NULL DEFAULT 0,
  `item77` smallint(6) NOT NULL DEFAULT 0,
  `item78` smallint(6) NOT NULL DEFAULT 0,
  `item79` smallint(6) NOT NULL DEFAULT 0,
  `item80` smallint(6) NOT NULL DEFAULT 0,
  `item81` smallint(6) NOT NULL DEFAULT 0,
  `item82` smallint(6) NOT NULL DEFAULT 0,
  `item83` smallint(6) NOT NULL DEFAULT 0,
  `item84` smallint(6) NOT NULL DEFAULT 0,
  `item85` smallint(6) NOT NULL DEFAULT 0,
  `item86` smallint(6) NOT NULL DEFAULT 0,
  `item87` smallint(6) NOT NULL DEFAULT 0,
  `item88` smallint(6) NOT NULL DEFAULT 0,
  `item89` smallint(6) NOT NULL DEFAULT 0,
  `item90` smallint(6) NOT NULL DEFAULT 0,
  `item91` smallint(6) NOT NULL DEFAULT 0,
  `item92` smallint(6) NOT NULL DEFAULT 0,
  `item93` smallint(6) NOT NULL DEFAULT 0,
  `item94` smallint(6) NOT NULL DEFAULT 0,
  `item95` smallint(6) NOT NULL DEFAULT 0,
  `item96` smallint(6) NOT NULL DEFAULT 0,
  `item97` smallint(6) NOT NULL DEFAULT 0,
  `item98` smallint(6) NOT NULL DEFAULT 0,
  `item99` smallint(6) NOT NULL DEFAULT 0,
  `item100` smallint(6) NOT NULL DEFAULT 0,
  `item101` smallint(6) NOT NULL DEFAULT 0,
  `item102` smallint(6) NOT NULL DEFAULT 0,
  `item103` smallint(6) NOT NULL DEFAULT 0,
  `item104` smallint(6) NOT NULL DEFAULT 0,
  `item105` smallint(6) NOT NULL DEFAULT 0,
  `item106` smallint(6) NOT NULL DEFAULT 0,
  `item107` smallint(6) NOT NULL DEFAULT 0,
  `item108` smallint(6) NOT NULL DEFAULT 0,
  `item109` smallint(6) NOT NULL DEFAULT 0,
  `item110` smallint(6) NOT NULL DEFAULT 0,
  `item111` smallint(6) NOT NULL DEFAULT 0,
  `item112` smallint(6) NOT NULL DEFAULT 0,
  `item113` smallint(6) NOT NULL DEFAULT 0,
  `item114` smallint(6) NOT NULL DEFAULT 0,
  `item115` smallint(6) NOT NULL DEFAULT 0,
  `item116` smallint(6) NOT NULL DEFAULT 0,
  `item117` smallint(6) NOT NULL DEFAULT 0,
  `item118` smallint(6) NOT NULL DEFAULT 0,
  `item119` smallint(6) NOT NULL DEFAULT 0,
  `item120` smallint(6) NOT NULL DEFAULT 0,
  `item121` smallint(6) NOT NULL DEFAULT 0,
  `item122` smallint(6) NOT NULL DEFAULT 0,
  `item123` smallint(6) NOT NULL DEFAULT 0,
  `item124` smallint(6) NOT NULL DEFAULT 0,
  `item125` smallint(6) NOT NULL DEFAULT 0,
  `item126` smallint(6) NOT NULL DEFAULT 0,
  `item127` smallint(6) NOT NULL DEFAULT 0,
  `item128` smallint(6) NOT NULL DEFAULT 0,
  `item129` smallint(6) NOT NULL DEFAULT 0,
  `item130` smallint(6) NOT NULL DEFAULT 0,
  `item131` smallint(6) NOT NULL DEFAULT 0,
  `item132` smallint(6) NOT NULL DEFAULT 0,
  `item133` smallint(6) NOT NULL DEFAULT 0,
  `item134` smallint(6) NOT NULL DEFAULT 0,
  `item135` smallint(6) NOT NULL DEFAULT 0,
  `item136` smallint(6) NOT NULL DEFAULT 0,
  `item137` smallint(6) NOT NULL DEFAULT 0,
  `item138` smallint(6) NOT NULL DEFAULT 0,
  `item139` smallint(6) NOT NULL DEFAULT 0,
  `item140` smallint(6) NOT NULL DEFAULT 0,
  `item141` smallint(6) NOT NULL DEFAULT 0,
  `item142` smallint(6) NOT NULL DEFAULT 0,
  `item143` smallint(6) NOT NULL DEFAULT 0,
  `item144` smallint(6) NOT NULL DEFAULT 0,
  `item145` smallint(6) NOT NULL DEFAULT 0,
  `item146` smallint(6) NOT NULL DEFAULT 0,
  `item147` smallint(6) NOT NULL DEFAULT 0,
  `item148` smallint(6) NOT NULL DEFAULT 0,
  `item149` smallint(6) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `sname` varchar(64) DEFAULT NULL,
  `pname` varchar(64) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `category` tinyint(4) DEFAULT -1,
  `healamount` smallint(6) DEFAULT -1,
  `wepid` smallint(6) DEFAULT -1,
  `ammoid` smallint(6) DEFAULT -1,
  `wepslot` tinyint(4) DEFAULT -1,
  `isusable` tinyint(4) DEFAULT 0,
  `maxresource` smallint(6) DEFAULT -1,
  `itemvalue` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `sname`, `pname`, `description`, `category`, `healamount`, `wepid`, `ammoid`, `wepslot`, `isusable`, `maxresource`, `itemvalue`) VALUES
(1, 'Scrap', 'Scrap', 'Some scrap metal. Might be useful for something.', 0, -1, -1, -1, -1, 1, -1, 3),
(2, 'Candy Bar', 'Candy Bars', 'It might be a bit out of date, but it will have to do for now.', 1, 5, -1, -1, -1, 1, -1, 8),
(3, 'Carton of Juice', 'Cartons of Juice', 'Freshly squeezed orange juice... or maybe it once was fresh.', 2, 5, -1, -1, -1, 1, -1, 12),
(4, 'Money', 'Monies', 'Useful to pay for things.', 0, -1, -1, -1, -1, 0, -1, 1),
(5, 'Baseball Bat', 'Baseball Bats', 'Normally used for baseball games... good for smashing heads in too.', 4, -1, 5, -1, 1, 1, -1, 80),
(6, '9mm Pistol', '9mm Pistols', 'A basic pistol which fires 9mm rounds.', 4, -1, 22, 7, 2, 1, -1, 350),
(7, '9mm Round', '9mm Rounds', 'Rounds of ammo used for 9mm pistols, Uzi, and Tec-9 weapons.', 5, -1, -1, -1, -1, 0, -1, 5),
(8, 'Shotgun', 'Shotguns', 'Good at close range. Fires 12 gauge shells.', 4, -1, 25, 9, 3, 1, -1, 600),
(9, '12 Gauge Shell', '12 Gauge Shells', 'Shells used with shotguns as ammo.', 5, -1, -1, -1, -1, 0, -1, 8),
(10, 'Bandage', 'Bandages', 'Used to stop bleeding from minor wounds.', 3, 5, -1, -1, -1, 1, -1, 25),
(11, 'Large Medical Kit', 'Large Medical Kits', 'A large medical kit full of all the supplies you might need for injuries.', 3, 100, -1, -1, -1, 1, -1, 800),
(12, 'Small Medical Kit', 'Small Medical Kits', 'A small medical kit with some basic medical supplies.', 3, 50, -1, -1, -1, 1, -1, 400),
(13, 'Medical Syringe', 'Medical Syringes', 'A syringe with some form of liquid medicine.', 3, 25, -1, -1, -1, 1, -1, 150),
(14, 'Paracetamol', 'Paracetamol', 'A small tablet that helps ease pain.', 3, 10, -1, -1, -1, 1, -1, 40),
(15, 'Uzi', 'Uzis', 'A submachine fun with a faster fire rate than a standard pistol while still using 9mm rounds.', 4, -1, 28, 7, 4, 1, -1, 500),
(16, 'Shovel', 'Shovels', 'Good at digging things up... or burying them.', 4, -1, 6, -1, 1, 1, -1, 60),
(17, 'Desert Eagle', 'Desert Eagles', 'Uses .44 ammo, a heavier and more powerful handgun.', 4, -1, 24, 18, 2, 1, -1, 700),
(18, '.44 Round', '.44 Rounds', 'Ammo used by the Desert Eagle.', 5, -1, -1, -1, -1, 0, -1, 10),
(19, 'Ration', 'Rations', 'A ration pack which greatly restores hunger.', 1, 50, -1, -1, -1, 1, -1, 120),
(20, 'Bottle of Water', 'Bottles of Water', 'Probably the most important liquid you could hope to find.', 2, 25, -1, -1, -1, 1, -1, 35),
(21, 'Chocolate Bar', 'Chocolate Bars', 'It might not be healthiest, but it is still tasty.', 1, 15, -1, -1, -1, 1, -1, 25),
(22, 'Biscuit', 'Biscuits', 'Very dry, but it staves off the hunger a little bit.', 1, 10, -1, -1, -1, 1, -1, 18),
(23, 'Canteen of Water', 'Canteens of Water', 'Bigger and heavier than a basic bottle of water, but also reusable!', 2, 45, -1, -1, -1, 1, -1, 90),
(24, 'Empty Canteen', 'Empty Canteens', 'Refillable canteen for liquid.', 0, -1, -1, -1, -1, 1, -1, 50),
(25, 'Canteen of Dirty Water', 'Canteens of Dirty Water', 'A canteen filled with dirty, unpurified water.', 2, 15, -1, -1, -1, 1, -1, 5),
(26, 'Purification Tablet', 'Purification Tablets', 'A purification tablet used to purify dirty water, making it safe to drink.', 0, -1, -1, -1, -1, 1, -1, 75),
(27, 'Antibiotic', 'Antibiotics', 'An antibiotic tablet used to cure disease.', 3, 10, -1, -1, -1, 1, -1, 200),
(28, 'Fuel Can', 'Fuel Cans', 'Holds fuel for vehicles or generators.', 0, -1, -1, -1, -1, 1, 30, 250),
(29, 'Nite Stick', 'Nite Sticks', 'A weapon normally used by the police in a more civilized time.', 4, -1, 3, -1, 1, 1, -1, 100),
(30, 'Scrap Cloth', 'Scrap Cloth', 'Some scrap cloth, maybe ripped from some clothing.', 0, -1, -1, -1, -1, 0, -1, 5),
(31, 'Knife', 'Knives', 'A sharp blade useful for close combat or survival tasks.', 4, -1, 4, -1, 1, 1, -1, 45),
(32, 'Chainsaw', 'Chainsaws', 'Extremely deadly in close quarters but very loud.', 4, -1, 9, -1, 1, 1, -1, 300),
(33, 'Silenced Pistol', 'Silenced Pistols', 'A 9mm pistol with a suppressor for stealth operations.', 4, -1, 23, 7, 2, 1, -1, 450),
(34, 'AK-47', 'AK-47s', 'A reliable assault rifle using 7.62mm rounds.', 4, -1, 30, 35, 5, 1, -1, 900),
(35, '7.62mm Round', '7.62mm Rounds', 'Ammunition for AK-47 rifles.', 5, -1, -1, -1, -1, 0, -1, 12),
(36, 'M4', 'M4s', 'A military-grade assault rifle using 5.56mm rounds.', 4, -1, 31, 37, 5, 1, -1, 1000),
(37, '5.56mm Round', '5.56mm Rounds', 'Ammunition for M4 rifles.', 5, -1, -1, -1, -1, 0, -1, 15),
(38, 'Sniper Rifle', 'Sniper Rifles', 'Long-range precision rifle. Very rare and valuable.', 4, -1, 34, 39, 6, 1, -1, 1500),
(39, 'Sniper Round', 'Sniper Rounds', 'High-caliber ammunition for sniper rifles.', 5, -1, -1, -1, -1, 0, -1, 20),
(40, 'Hunting Rifle', 'Hunting Rifles', 'A civilian rifle good for hunting and long-range defense.', 4, -1, 33, 39, 6, 1, -1, 750),
(41, 'Canned Beans', 'Cans of Beans', 'Protein-rich canned food. Lasts forever.', 1, 30, -1, -1, -1, 1, -1, 45),
(42, 'Canned Soup', 'Cans of Soup', 'Warm soup in a can. Filling and nutritious.', 1, 35, -1, -1, -1, 1, -1, 55),
(43, 'Energy Drink', 'Energy Drinks', 'Restores thirst and gives a small energy boost.', 2, 20, -1, -1, -1, 1, -1, 30),
(44, 'Soda Can', 'Soda Cans', 'Sugary drink that quenches thirst.', 2, 15, -1, -1, -1, 1, -1, 20),
(45, 'MRE', 'MREs', 'Military Meal Ready-to-Eat. Highly nutritious survival food.', 1, 70, -1, -1, -1, 1, -1, 180),
(46, 'Flashlight', 'Flashlights', 'Useful for seeing in the dark. Requires batteries.', 0, -1, -1, -1, -1, 1, -1, 65),
(47, 'Battery', 'Batteries', 'Provides power for electronic devices.', 0, -1, -1, -1, -1, 0, -1, 15),
(48, 'Rope', 'Ropes', 'Useful for climbing, crafting, or securing things.', 0, -1, -1, -1, -1, 0, -1, 40),
(49, 'Duct Tape', 'Rolls of Duct Tape', 'Fixes almost anything. Essential survival item.', 0, -1, -1, -1, -1, 0, -1, 35),
(50, 'Matches', 'Boxes of Matches', 'For starting fires. Handle with care.', 0, -1, -1, -1, -1, 1, -1, 20),
(51, 'Lighter', 'Lighters', 'Reusable fire starter. More reliable than matches.', 0, -1, -1, -1, -1, 1, -1, 30),
(52, 'Backpack', 'Backpacks', 'Increases carrying capacity.', 0, -1, -1, -1, -1, 1, -1, 150),
(53, 'Toolbox', 'Toolboxes', 'Contains basic tools for repairs and crafting.', 0, -1, -1, -1, -1, 1, -1, 200),
(54, 'Binoculars', 'Binoculars', 'Allows you to scout ahead safely.', 0, -1, -1, -1, -1, 1, -1, 120),
(55, 'Radio', 'Radios', 'Communication device. Requires batteries.', 0, -1, -1, -1, -1, 1, -1, 180),
(56, 'Gas Mask', 'Gas Masks', 'Protects against airborne threats.', 0, -1, -1, -1, -1, 1, -1, 350),
(57, 'Body Armor', 'Body Armor', 'Provides protection against physical damage.', 0, -1, -1, -1, -1, 1, -1, 600),
(58, 'Sleeping Bag', 'Sleeping Bags', 'Portable bedding for rest and warmth.', 0, -1, -1, -1, -1, 1, -1, 85),
(59, 'Tent', 'Tents', 'Provides shelter from the elements.', 0, -1, -1, -1, -1, 1, -1, 220),
(60, 'Compass', 'Compasses', 'Never get lost again with this navigation tool.', 0, -1, -1, -1, -1, 1, -1, 75);

-- --------------------------------------------------------

--
-- Table structure for table `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `author` varchar(24) NOT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `page_content`
--

CREATE TABLE `page_content` (
  `id` int(11) NOT NULL,
  `page_name` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `last_updated` int(11) NOT NULL,
  `updated_by` varchar(24) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
-- --------------------------------------------------------

--
-- Table structure for table `scavareas`
--

CREATE TABLE `scavareas` (
  `id` int(11) NOT NULL,
  `posx` float DEFAULT NULL,
  `posy` float DEFAULT NULL,
  `posz` float DEFAULT NULL,
  `interior` int(11) DEFAULT NULL,
  `world` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

CREATE TABLE `shops` (
  `id` int(11) NOT NULL,
  `actor_skin` int(11) NOT NULL DEFAULT 0,
  `shopx` float NOT NULL,
  `shopy` float NOT NULL,
  `shopz` float NOT NULL,
  `shopa` float NOT NULL DEFAULT 0.0,
  `shopint` int(11) NOT NULL DEFAULT 0,
  `shopworld` int(11) NOT NULL DEFAULT 0,
  `item1` int(11) NOT NULL DEFAULT 0,
  `item2` int(11) NOT NULL DEFAULT 0,
  `item3` int(11) NOT NULL DEFAULT 0,
  `item4` int(11) NOT NULL DEFAULT 0,
  `item5` int(11) NOT NULL DEFAULT 0,
  `item6` int(11) NOT NULL DEFAULT 0,
  `item7` int(11) NOT NULL DEFAULT 0,
  `item8` int(11) NOT NULL DEFAULT 0,
  `item9` int(11) NOT NULL DEFAULT 0,
  `item10` int(11) NOT NULL DEFAULT 0,
  `item11` int(11) NOT NULL DEFAULT 0,
  `item12` int(11) NOT NULL DEFAULT 0,
  `item13` int(11) NOT NULL DEFAULT 0,
  `item14` int(11) NOT NULL DEFAULT 0,
  `item15` int(11) NOT NULL DEFAULT 0,
  `item16` int(11) NOT NULL DEFAULT 0,
  `item17` int(11) NOT NULL DEFAULT 0,
  `item18` int(11) NOT NULL DEFAULT 0,
  `item19` int(11) NOT NULL DEFAULT 0,
  `item20` int(11) NOT NULL DEFAULT 0,
  `item21` int(11) NOT NULL DEFAULT 0,
  `item22` int(11) NOT NULL DEFAULT 0,
  `item23` int(11) NOT NULL DEFAULT 0,
  `item24` int(11) NOT NULL DEFAULT 0,
  `item25` int(11) NOT NULL DEFAULT 0,
  `item26` int(11) NOT NULL DEFAULT 0,
  `item27` int(11) NOT NULL DEFAULT 0,
  `item28` int(11) NOT NULL DEFAULT 0,
  `item29` int(11) NOT NULL DEFAULT 0,
  `item30` int(11) NOT NULL DEFAULT 0,
  `item31` int(11) NOT NULL DEFAULT 0,
  `item32` int(11) NOT NULL DEFAULT 0,
  `item33` int(11) NOT NULL DEFAULT 0,
  `item34` int(11) NOT NULL DEFAULT 0,
  `item35` int(11) NOT NULL DEFAULT 0,
  `item36` int(11) NOT NULL DEFAULT 0,
  `item37` int(11) NOT NULL DEFAULT 0,
  `item38` int(11) NOT NULL DEFAULT 0,
  `item39` int(11) NOT NULL DEFAULT 0,
  `item40` int(11) NOT NULL DEFAULT 0,
  `item41` int(11) NOT NULL DEFAULT 0,
  `item42` int(11) NOT NULL DEFAULT 0,
  `item43` int(11) NOT NULL DEFAULT 0,
  `item44` int(11) NOT NULL DEFAULT 0,
  `item45` int(11) NOT NULL DEFAULT 0,
  `item46` int(11) NOT NULL DEFAULT 0,
  `item47` int(11) NOT NULL DEFAULT 0,
  `item48` int(11) NOT NULL DEFAULT 0,
  `item49` int(11) NOT NULL DEFAULT 0,
  `item50` int(11) NOT NULL DEFAULT 0,
  `item51` int(11) NOT NULL DEFAULT 0,
  `item52` int(11) NOT NULL DEFAULT 0,
  `item53` int(11) NOT NULL DEFAULT 0,
  `item54` int(11) NOT NULL DEFAULT 0,
  `item55` int(11) NOT NULL DEFAULT 0,
  `item56` int(11) NOT NULL DEFAULT 0,
  `item57` int(11) NOT NULL DEFAULT 0,
  `item58` int(11) NOT NULL DEFAULT 0,
  `item59` int(11) NOT NULL DEFAULT 0,
  `item60` int(11) NOT NULL DEFAULT 0,
  `item61` int(11) NOT NULL DEFAULT 0,
  `item62` int(11) NOT NULL DEFAULT 0,
  `item63` int(11) NOT NULL DEFAULT 0,
  `item64` int(11) NOT NULL DEFAULT 0,
  `item65` int(11) NOT NULL DEFAULT 0,
  `item66` int(11) NOT NULL DEFAULT 0,
  `item67` int(11) NOT NULL DEFAULT 0,
  `item68` int(11) NOT NULL DEFAULT 0,
  `item69` int(11) NOT NULL DEFAULT 0,
  `item70` int(11) NOT NULL DEFAULT 0,
  `item71` int(11) NOT NULL DEFAULT 0,
  `item72` int(11) NOT NULL DEFAULT 0,
  `item73` int(11) NOT NULL DEFAULT 0,
  `item74` int(11) NOT NULL DEFAULT 0,
  `item75` int(11) NOT NULL DEFAULT 0,
  `item76` int(11) NOT NULL DEFAULT 0,
  `item77` int(11) NOT NULL DEFAULT 0,
  `item78` int(11) NOT NULL DEFAULT 0,
  `item79` int(11) NOT NULL DEFAULT 0,
  `item80` int(11) NOT NULL DEFAULT 0,
  `item81` int(11) NOT NULL DEFAULT 0,
  `item82` int(11) NOT NULL DEFAULT 0,
  `item83` int(11) NOT NULL DEFAULT 0,
  `item84` int(11) NOT NULL DEFAULT 0,
  `item85` int(11) NOT NULL DEFAULT 0,
  `item86` int(11) NOT NULL DEFAULT 0,
  `item87` int(11) NOT NULL DEFAULT 0,
  `item88` int(11) NOT NULL DEFAULT 0,
  `item89` int(11) NOT NULL DEFAULT 0,
  `item90` int(11) NOT NULL DEFAULT 0,
  `item91` int(11) NOT NULL DEFAULT 0,
  `item92` int(11) NOT NULL DEFAULT 0,
  `item93` int(11) NOT NULL DEFAULT 0,
  `item94` int(11) NOT NULL DEFAULT 0,
  `item95` int(11) NOT NULL DEFAULT 0,
  `item96` int(11) NOT NULL DEFAULT 0,
  `item97` int(11) NOT NULL DEFAULT 0,
  `item98` int(11) NOT NULL DEFAULT 0,
  `item99` int(11) NOT NULL DEFAULT 0,
  `item100` int(11) NOT NULL DEFAULT 0,
  `item101` int(11) NOT NULL DEFAULT 0,
  `item102` int(11) NOT NULL DEFAULT 0,
  `item103` int(11) NOT NULL DEFAULT 0,
  `item104` int(11) NOT NULL DEFAULT 0,
  `item105` int(11) NOT NULL DEFAULT 0,
  `item106` int(11) NOT NULL DEFAULT 0,
  `item107` int(11) NOT NULL DEFAULT 0,
  `item108` int(11) NOT NULL DEFAULT 0,
  `item109` int(11) NOT NULL DEFAULT 0,
  `item110` int(11) NOT NULL DEFAULT 0,
  `item111` int(11) NOT NULL DEFAULT 0,
  `item112` int(11) NOT NULL DEFAULT 0,
  `item113` int(11) NOT NULL DEFAULT 0,
  `item114` int(11) NOT NULL DEFAULT 0,
  `item115` int(11) NOT NULL DEFAULT 0,
  `item116` int(11) NOT NULL DEFAULT 0,
  `item117` int(11) NOT NULL DEFAULT 0,
  `item118` int(11) NOT NULL DEFAULT 0,
  `item119` int(11) NOT NULL DEFAULT 0,
  `item120` int(11) NOT NULL DEFAULT 0,
  `item121` int(11) NOT NULL DEFAULT 0,
  `item122` int(11) NOT NULL DEFAULT 0,
  `item123` int(11) NOT NULL DEFAULT 0,
  `item124` int(11) NOT NULL DEFAULT 0,
  `item125` int(11) NOT NULL DEFAULT 0,
  `item126` int(11) NOT NULL DEFAULT 0,
  `item127` int(11) NOT NULL DEFAULT 0,
  `item128` int(11) NOT NULL DEFAULT 0,
  `item129` int(11) NOT NULL DEFAULT 0,
  `item130` int(11) NOT NULL DEFAULT 0,
  `item131` int(11) NOT NULL DEFAULT 0,
  `item132` int(11) NOT NULL DEFAULT 0,
  `item133` int(11) NOT NULL DEFAULT 0,
  `item134` int(11) NOT NULL DEFAULT 0,
  `item135` int(11) NOT NULL DEFAULT 0,
  `item136` int(11) NOT NULL DEFAULT 0,
  `item137` int(11) NOT NULL DEFAULT 0,
  `item138` int(11) NOT NULL DEFAULT 0,
  `item139` int(11) NOT NULL DEFAULT 0,
  `item140` int(11) NOT NULL DEFAULT 0,
  `item141` int(11) NOT NULL DEFAULT 0,
  `item142` int(11) NOT NULL DEFAULT 0,
  `item143` int(11) NOT NULL DEFAULT 0,
  `item144` int(11) NOT NULL DEFAULT 0,
  `item145` int(11) NOT NULL DEFAULT 0,
  `item146` int(11) NOT NULL DEFAULT 0,
  `item147` int(11) NOT NULL DEFAULT 0,
  `item148` int(11) NOT NULL DEFAULT 0,
  `item149` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wiki_articles`
--

CREATE TABLE `wiki_articles` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `content` longtext NOT NULL,
  `author` varchar(24) NOT NULL,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL,
  `last_edited_by` varchar(24) NOT NULL,
  `views` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wiki_categories`
--

CREATE TABLE `wiki_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `display_order` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `admin_logs`
--
ALTER TABLE `admin_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_account_id` (`admin_account_id`),
  ADD KEY `timestamp` (`timestamp`),
  ADD KEY `command` (`command`);

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `owner` (`owner`);

--
-- Indexes for table `crafting_recipes`
--
ALTER TABLE `crafting_recipes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `character_recipes`
--
ALTER TABLE `character_recipes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `character_name` (`character_name`),
  ADD KEY `recipe_id` (`recipe_id`);

--
-- Indexes for table `factions`
--
ALTER TABLE `factions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faction_members`
--
ALTER TABLE `faction_members`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faction_ranks`
--
ALTER TABLE `faction_ranks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faction_territories`
--
ALTER TABLE `faction_territories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fuelpump`
--
ALTER TABLE `fuelpump`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `interiors`
--
ALTER TABLE `interiors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `character` (`character`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loottable`
--
ALTER TABLE `loottable`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `page_content`
--
ALTER TABLE `page_content`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `page_name` (`page_name`);

--
-- Indexes for table `scavareas`
--
ALTER TABLE `scavareas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `wiki_articles`
--
ALTER TABLE `wiki_articles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `wiki_categories`
--
ALTER TABLE `wiki_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `admin_logs`
--
ALTER TABLE `admin_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crafting_recipes`
--
ALTER TABLE `crafting_recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `character_recipes`
--
ALTER TABLE `character_recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `factions`
--
ALTER TABLE `factions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faction_members`
--
ALTER TABLE `faction_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faction_ranks`
--
ALTER TABLE `faction_ranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faction_territories`
--
ALTER TABLE `faction_territories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fuelpump`
--
ALTER TABLE `fuelpump`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `interiors`
--
ALTER TABLE `interiors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `loottable`
--
ALTER TABLE `loottable`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `page_content`
--
ALTER TABLE `page_content`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scavareas`
--
ALTER TABLE `scavareas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wiki_articles`
--
ALTER TABLE `wiki_articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wiki_categories`
--
ALTER TABLE `wiki_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
