// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("AlegraStudioReward", "ASR") {}
    
    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}

contract AlegraStudio is AccessControl, Pausable {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct Project {
        string name;
        bool isActive;
    }

    Project[] public projects;
    RewardToken public rewardToken;

    mapping(address => mapping(uint256 => bool)) public userBadges;
    mapping(address => uint256) public userRewards;

    event ProjectRegistered(string name, uint256 projectId);
    event UserParticipated(address indexed user, uint256 projectId);
    event RewardIssued(address indexed user, uint256 amount, uint256 projectId);

    constructor(address _rewardToken) {
        _setupRole(ADMIN_ROLE, msg.sender);
        rewardToken = RewardToken(_rewardToken);
    }

    function registerProject(string memory _name) external onlyRole(ADMIN_ROLE) whenNotPaused {
        projects.push(Project({name: _name, isActive: true}));
        emit ProjectRegistered(_name, projects.length - 1);
    }

    function participate(uint256 _projectId) external whenNotPaused {
        require(_projectId < projects.length, "Invalid project");
        require(projects[_projectId].isActive, "Project is not active");
        emit UserParticipated(msg.sender, _projectId);
    }

    function issueReward(address _user, uint256 _amount, uint256 _projectId) external onlyRole(ADMIN_ROLE) whenNotPaused {
        require(_projectId < projects.length, "Invalid project");
        userRewards[_user] = userRewards[_user].add(_amount);
        rewardToken.mint(_user, _amount);
        emit RewardIssued(_user, _amount, _projectId);
    }

    function grantBadge(address _user, uint256 _projectId) external onlyRole(ADMIN_ROLE) {
        require(_projectId < projects.length, "Invalid project");
        userBadges[_user][_projectId] = true;
    }

    function verifyBadge(address _user, uint256 _projectId) external view returns (bool) {
        require(_projectId < projects.length, "Invalid project");
        return userBadges[_user][_projectId];
    }

    function transferReward(address _recipient, uint256 _amount) external whenNotPaused {
        require(userRewards[msg.sender] >= _amount, "Insufficient reward balance");
        rewardToken.transferFrom(msg.sender, _recipient, _amount);
        userRewards[msg.sender] = userRewards[msg.sender].sub(_amount);
        userRewards[_recipient] = userRewards[_recipient].add(_amount);
    }

    function deactivateProject(uint256 _projectId) external onlyRole(ADMIN_ROLE) {
        require(_projectId < projects.length, "Invalid project");
        projects[_projectId].isActive = false;
    }

    function pauseContract() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpauseContract() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}
