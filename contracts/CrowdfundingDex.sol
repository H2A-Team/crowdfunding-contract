// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";

contract CrowdfundingDex {
    using Strings for string;

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
        string logoUrl;
        string coverBackgroundUrl;
        TokenInformation tokenInformation;
        ProjectSchedule schedule;
        ProjectAllocation allocation;
    }

    struct CreateProjectDTO {
        string name;
        string slug;
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

    Project[] internal projectList;
    string[] internal slugPool;

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

        // create slug

        globalProjectIdCount++;
        string memory projectSlug = createSlug(dto.slug);
        slugPool.push(projectSlug);

        Project memory project = Project(
            globalProjectIdCount,
            msg.sender,
            dto.name,
            projectSlug,
            dto.shortDescription,
            dto.description,
            dto.logoUrl,
            dto.coverBackgroundUrl,
            TokenInformation(dto.tokenSymbol, dto.tokenSwapRaito),
            ProjectSchedule(block.timestamp, dto.opensAt, dto.endsAt, dto.idoStartsAt, dto.idoEndsAt),
            ProjectAllocation(dto.maxAllocation, dto.totalRaise)
        );
        projectList.push(project);

        globalProjectCount++;
        return project.id;
    }

    function getProjectList() public view returns (Project[] memory) {
        return projectList;
    }

    function createSlug(string calldata str) private view returns (string memory) {
        string memory slug = str;
        while (isSlugBoolInclude(slug)) {
            uint randNum = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
            slug = string.concat(str, "-", Strings.toString(randNum));
        }

        return slug;
    }

    function isSlugBoolInclude(string memory str) view private returns (bool) {
        for (uint i = 0; i < slugPool.length; i++) {
            string memory current = slugPool[i];

            if (current.equal(str)) {
                return true;
            }
        }
        return false;
    }
}
