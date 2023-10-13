// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../common/IERC20.sol";

contract Airdrop {
    mapping(address => uint) failTransferList;

    function multiTransferToken(address _token, address[] calldata _addresses, uint256[] calldata _amounts) external {
        require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts Not Equal!");
        IERC20 token = IERC20(_token);
        uint _amountSum = getSum(_amounts);
        require(token.allowance(msg.sender, address(this)) > _amountSum, "Need Approve ERC20 token");
        for (uint256 i; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
    }

    function multiTransferETH(address payable[] calldata _addresses, uint256[] calldata _amounts) public payable {
        require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts Not Equal");
        uint _amountSum = getSum(_amounts);
        require(msg.value == _amountSum, "Transfer amount error");
        for (uint256 i = 0; i < _addresses.length; i++) {
            (bool success, ) = _addresses[i].call{value: _amounts[i]}("");
            if (!success) {
                failTransferList[_addresses[i]] = _amounts[i];
            }
        }
    }

    function withdrawFromFailList(address _to) public {
        uint failAmount = failTransferList[msg.sender];
        require(failAmount > 0, "You are not in failed list");
        failTransferList[msg.sender] = 0;
        (bool success, ) = _to.call{value: failAmount}("");
        require(success, "Fail withdraw");
    }

    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) {
            sum += _arr[i];
        }
    }
}