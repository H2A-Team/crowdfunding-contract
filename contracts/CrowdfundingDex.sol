// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";

contract CrowdfundingDex {
    using Strings for string;

    enum ProjectState { APPLICATION_CREATED, APPLICATION_OPEN, APPLICATION_CLOSED, PUBLISHED }

    struct Investor {
        uint256 stakeTime;
        uint256 stakeAmount;
    }

    struct TokenInformation {
        string symbol;
        string swapRaito;
        // address tokenAddress;
    }

    struct ProjectSchedule {
        uint256 createdAt;
        uint256 opensAt;
        uint256 endsAt;
        uint256 idoStartsAt;
        uint256 idoEndsAt;
    }

    struct ProjectAllocation {
        uint256 maxAllocation;
        uint256 totalRaise;
    }

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
        ProjectSchedule schedule;
        ProjectAllocation allocation;
    }
    mapping(uint256 => Project) internal projectList;

    struct CreateProjectDTO {
        string name;
        string shortDescription;
        string description;
        string logoUrl;
        string coverBackgroundUrl;
        uint256 maxAllocation;
        uint256 totalRaise;
        string tokenSymbol;
        // string tokenAddress;
        string tokenSwapRaito;
        uint256 opensAt;
        uint256 endsAt;
        uint256 idoStartsAt;
        uint256 idoEndsAt;
    }

    // Mapping: projectId -> list of project's investors
    mapping(uint256 => Investor[]) internal projectInvestorMap;

    uint256 globalProjectIdCount = 0;
    uint256 globalProjectCount = 0;

    modifier validSender {
        if (msg.sender == address(0)) {
            revert("Invalid sender address");
        }
        _;
    }

    function createProject(CreateProjectDTO calldata dto) validSender public returns (uint256) {
        require(!dto.name.equal(""), "Project name is required");
        require(!dto.shortDescription.equal(""), "Project headline is required");
        require(!dto.description.equal(""), "Project description is required");
        require(dto.maxAllocation > 0, "Max allocation must larger than 0");
        require(dto.totalRaise > 0, "Total raise must larger than 0");
        require(!dto.tokenSymbol.equal(""), "Missing token symbol");

        require(dto.opensAt > block.timestamp, "Open date should be a date in future");
        require(dto.endsAt > dto.opensAt, "Allocation end date should be larger than open date");
        require(dto.idoStartsAt >= dto.endsAt, "IDO start date should be larger than the end date");
        require(dto.idoEndsAt >= dto.idoStartsAt, "IDO end date should be larger than IDO start date");

        Project storage project = projectList[globalProjectCount];
        globalProjectIdCount++;

        project.id = globalProjectIdCount;
        project.name = dto.name;
        project.shortDescription = dto.shortDescription;
        project.description = dto.description;
        project.logoUrl = dto.logoUrl;
        project.coverBackgroundUrl = dto.coverBackgroundUrl;

        project.allocation.maxAllocation = dto.maxAllocation;
        project.allocation.totalRaise = dto.totalRaise;

        project.state = ProjectState.APPLICATION_CREATED;

        project.tokenInformation.symbol = dto.tokenSymbol;
        project.tokenInformation.swapRaito = dto.tokenSwapRaito;

        project.schedule.createdAt = block.timestamp;
        project.schedule.opensAt = dto.opensAt;
        project.schedule.endsAt = dto.endsAt;
        project.schedule.idoStartsAt = dto.idoStartsAt;
        project.schedule.idoEndsAt = dto.idoEndsAt;

        globalProjectCount++;
        return project.id;
    }
}
