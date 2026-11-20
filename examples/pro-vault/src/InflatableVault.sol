// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./MockToken.sol";

/// @notice A deliberately vulnerable share vault, written for teaching.
/// The bug: the share price is computed from the vault's live token
/// balance, so anyone can inflate it with a direct donation — and
/// there is no minimum-share check on deposit. The next depositor
/// can receive zero shares while their funds stay in the vault.
/// Do NOT deploy this. See test/PoC_ShareInflation.t.sol for the proof.
contract InflatableVault {
    MockToken public immutable token;

    uint256 public totalSupply; // shares
    mapping(address => uint256) public balanceOf;

    constructor(MockToken _token) {
        token = _token;
    }

    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function deposit(uint256 amount) external returns (uint256 shares) {
        uint256 assetsBefore = totalAssets();
        require(token.transferFrom(msg.sender, address(this), amount), "transfer failed");
        if (totalSupply == 0) {
            shares = amount;
        } else {
            shares = (amount * totalSupply) / assetsBefore;
        }
        // BUG: no minimum-share check. When the share price has been
        // inflated, a large deposit can mint zero shares.
        totalSupply += shares;
        balanceOf[msg.sender] += shares;
    }

    function withdraw(uint256 shares) external returns (uint256 assets) {
        require(balanceOf[msg.sender] >= shares, "insufficient shares");
        assets = (shares * totalAssets()) / totalSupply;
        totalSupply -= shares;
        balanceOf[msg.sender] -= shares;
        require(token.transfer(msg.sender, assets), "transfer failed");
    }
}
