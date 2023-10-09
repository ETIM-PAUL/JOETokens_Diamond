// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";

import "../interfaces/IERC20.sol";

error InsufficientAllowance();

contract JoeTokenFacet is IERC20 {
    TokenStorage s;

    function name() external pure returns (string memory) {
        return "Joe Token";
    }

    function symbol() external pure returns (string memory) {
        return "JOE";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return s.totalSupply;
    }

    function balanceOf(
        address _owner
    ) external view override returns (uint256 balance) {
        balance = s.balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) external override returns (bool success) {
        LibERC20.transfer(s, msg.sender, _to, _value);
        success = true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool success) {
        uint256 _allowance = s.allowances[_from][msg.sender];
        if (_allowance < _value) revert InsufficientAllowance();

        LibERC20.transfer(s, _from, _to, _value);
        unchecked {
            s.allowances[_from][msg.sender] -= _value;
        }

        success = true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) external override returns (bool success) {
        LibERC20.approve(s, msg.sender, _spender, _value);
        success = true;
    }

    function allowance(
        address _owner,
        address _spender
    ) external view override returns (uint256 remaining) {
        remaining = s.allowances[_owner][_spender];
    }
}
