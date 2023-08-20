// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract CrowdfundingDex {
    using SafeMath for uint64;
    using SafeMath for uint96;
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeCast for uint48;

    enum ProjectState {
        APPLICATION_OPEN,
        PUBLISHED
    }

    // Investor object
    struct Investor {
        uint256 stakeTime;
        uint256 stakeAmount;
    }
    mapping(address => Investor) public investorList;

    struct TokenInformation {
        string name;
        string symbol;
        address tokenAddress;
        uint256 swapRaito;
    }

    struct Social {
        string websiteUrl;
        string twitterHandle;
        string whitepaperUrl;
        string mediumUrl;
    }

    struct ProjectSchedule {
        uint256 createdAt;
        uint256 opensAt;
        uint256 endsAt;
        uint256 idoStartAt;
        uint256 idoEndsAt;
    }

    struct ProjectAllocation {
        uint256 maxAllocation;
        uint256 totalRaise;
    }

    // Project
    struct Project {
        uint256 id;
        address owner;
        string name;
        string slug;
        string shortDescription;
        string description;
        ProjectState state;
        string logoUrl;
        string coverBackgroundUrl;
        TokenInformation tokenInformation;
        Social social;
        ProjectSchedule schedule;
        ProjectAllocation allocation;
    }
    mapping(uint256 => Project) public projectList;
}
