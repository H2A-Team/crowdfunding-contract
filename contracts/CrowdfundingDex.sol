// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";

contract CrowdfundingDex {
    using Strings for string;

    struct VestingInfor {
        uint256 stakeAmountInWei;
        uint256 stakeTime;
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
        uint256 currentRaise;
        uint256 totalParticipants;
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

    struct DexMetrics {
        uint256 totalProjects;
        uint256 uniqueParticipants;
        uint256 totalRaised;
    }

    mapping(uint256 => mapping(address => VestingInfor[])) internal projectToInvestorMap;
    //check unque user in project
    mapping(uint256 => mapping(address => bool)) internal uniqueProjectInvestorMap;
    // check unique user
    mapping(address => bool) internal uniqueParticipantMap;

    uint256 globalProjectIdCount = 0;
    uint256 globalUniqeParticipantCount = 0;

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

        require(dto.opensAt > block.timestamp * 1000, "Open date should be a date in future");
        require(dto.endsAt > dto.opensAt, "Allocation end date should be larger than open date");
        require(dto.idoStartsAt >= dto.endsAt, "IDO start date should be larger than the end date");
        require(dto.idoEndsAt >= dto.idoStartsAt, "IDO end date should be larger than IDO start date");

        globalProjectIdCount++;
        // create slug
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
            ProjectSchedule(block.timestamp * 1000, dto.opensAt, dto.endsAt, dto.idoStartsAt, dto.idoEndsAt),
            ProjectAllocation(dto.maxAllocation, dto.totalRaise),
            0,
            0
        );
        projectList.push(project);

        return project.id;
    }

    function getProjectList() public view returns (Project[] memory) {
        return projectList;
    }

    function stakingInProject(uint256 projectId) validSender public payable {
        // validate project id
        int index = findIndexOfProject(projectId);

        if (index == -1) {
            revert("Invalid project id");
        }

        Project storage project =  projectList[uint(index)];
        uint userStakeInWei = msg.value;

        // check stake time is early or late
        require(block.timestamp * 1000 >= project.schedule.opensAt && block.timestamp * 1000 <= project.schedule.endsAt, "Project staking is not opened");

        // check min allocation
        require(userStakeInWei > 0, "Not enough money");

        // check valid allocation
        VestingInfor[] storage vestingList = projectToInvestorMap[project.id][msg.sender];

        uint256 totalStakeInWei = 0;
        for (uint i = 0; i < vestingList.length; i++) {
            totalStakeInWei += vestingList[i].stakeAmountInWei;
        }

        require(totalStakeInWei + userStakeInWei <= project.allocation.maxAllocation * (10**18), "Too much money");

        // add amount to storage
        project.currentRaise += userStakeInWei;

        // add investor to project
        if (!uniqueProjectInvestorMap[project.id][msg.sender]) {
            project.totalParticipants++;
            uniqueProjectInvestorMap[project.id][msg.sender] = true;
        }

        vestingList.push(VestingInfor(userStakeInWei, block.timestamp * 1000));

        // count global participant
        if (!uniqueParticipantMap[msg.sender]) {
            uniqueParticipantMap[msg.sender] = true;
            globalUniqeParticipantCount++;
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getDexMetris() public view returns (DexMetrics memory) {
        uint256 totalRaised = 0;

        for (uint i = 0; i < projectList.length; i++) {
            totalRaised += projectList[i].currentRaise;
        }

        return DexMetrics(projectList.length, globalUniqeParticipantCount, totalRaised);
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

    function findIndexOfProject(uint256 projectId) private view returns (int) {
        for (uint i = 0; i < projectList.length; i++) {
            if (projectList[i].id == projectId) {
                return int(i);
            }
        }

        return -1;
    }
}
