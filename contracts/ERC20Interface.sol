// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Interface for contracts conforming to ERC-20
 */

interface ERC20Interface {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);
    function transfer(address recipient, uint256 amount) external returns (bool success);
  function approve(address spender, uint256 amount) external returns (bool success);
}
