pragma solidity 0.6.6;

interface IProjectSchema {
    struct ProjectRecord {
        address projectId;
        address payable projectCreator;
        string projectTitle;
        string projectDescription;
        uint256 deadlineInSeconds;
        uint256 durationInSeconds;
        string  projectUrl;
        uint256 totalAmountContributed;
        uint256 numberOfContributors;
        uint256 goal;
        ContributorRecord[] contributors;
        SpendingRequest[] spendingRequest
    }

    struct ContributorRecord {
        bool exist;
        address projectId;
        address funder;
        uint _funderId;
        uint256 amountContributed;
    }
    
    struct SpendingRequest {
        uint256 spendingRequestId;
        string description;
        uint256 value;
        bool exist;
        address payable recipient;
        bool isCompleted;
        uint256 numberOfVoters;
    }
}
