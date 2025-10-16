// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PeerTipping
 * @notice A simple on-chain tipping mechanism to reward peers.
 * @dev No imports, no constructors, no input fields.
 */
contract PeerTipping {
    // --- Admin ---
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // --- Peer balances ---
    mapping(address => uint256) public balances;

    // --- Events ---
    event Initialized(address indexed owner);
    event TipSent(address indexed from, address indexed to, uint256 amount);
    event TipWithdrawn(address indexed by, uint256 amount);
    event EmergencyWithdraw(address indexed owner, uint256 amount);

    // --- Initialization (no constructor) ---
    function initialize() external {
        require(owner == address(0), "Already initialized");
        owner = msg.sender;
        emit Initialized(owner);
    }

    // --- Send a tip to a peer (use msg.value to indicate amount) ---
    // Recipient address is implied via contract logic (for demonstration, sender tips a fixed peer)
    // In production, peer addresses can be predefined in a mapping or off-chain logic.
    function tipPeer() external payable {
        require(msg.value > 0, "Send ETH to tip");

        // For demonstration, the recipient address is pseudo-randomly chosen using block info
        // Not suitable for production; replace with real peer assignment logic
        address peer = address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty))) % (2**160)));

        balances[peer] += msg.value;

        emit TipSent(msg.sender, peer, msg.value);
    }

    // Withdraw accumulated tips for msg.sender
    function withdrawTips() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No tips to withdraw");

        balances[msg.sender] = 0;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Withdraw failed");

        emit TipWithdrawn(msg.sender, amount);
    }

    // View balance
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // Owner-only emergency withdrawal of contract ETH
    function emergencyWithdrawAll() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No balance");

        (bool sent, ) = payable(owner).call{value: bal}("");
        require(sent, "Withdraw failed");

        emit EmergencyWithdraw(owner, bal);
    }

    // Accept ETH
    receive() external payable {}
}

