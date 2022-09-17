//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712 {

    ERC20 drm;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private _nonces;
    bytes32 _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    //bytes32 private DOMAIN_SEPARATOR;

    string private _name;
    string private _symbol;
    

    bool private _paused;

    uint8 private _decimals;
    uint256 private _totalSupply;
    uint nonce;

    constructor(string memory name, string memory symbol) EIP712(name, "4"){
        name = _name;
        symbol = _symbol;

        _paused = false;
        _decimals = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
    
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }   

    function balanceOf(address _to) public view returns (uint256){
        return balances[_to];
    }

    function approve(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "transferfrom the zero address");
        require(_to != address(0), "transferfrom the zero address");
        require(balances[_from] >= _value, "Value exceeds balance");

        allowances[_from][_to] = _value;
        if(allowances[_from][_to] > 0){
            return true;
        }
        else{
            return false;
        }
    }


    function transfer(address _to, uint256 _value) public returns (bool success){
        require(msg.sender != address(0), "Invalid From address");
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "vaule exceeds balance");
        
    
        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }


    function allowance(address _to, address _from) public view returns (uint256){
        return allowances[_to][_from];
    }   

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(msg.sender != address(0), "transferfrom the zero address");
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
    
        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }
    }

    function _mint(address owner, uint256 _value) internal{
        require(owner != address(0), "transferfrom the zero address");
        require(balances[owner]+_value <= type(uint256).max);
        _totalSupply += _value;
        balances[owner] += _value;

        emit Transfer(address(0), owner, _value);
    }

    function _burn(address owner, uint256 _value) internal{
        require(owner != address(0), "transferfrom the zero address");
        require(balances[owner] >= _value, "vaule exceeds balance");
        balances[owner] -= _value;
        _totalSupply -= _value;

        emit Transfer(owner, address(0), _value);
    }

    function pause() public {
        require(_paused);
        //_paused = true;
        emit Paused();
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        nonce = _nonces[owner];
        _nonces[owner] += 1;

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH,owner,spender,value,nonce,deadline));
        bytes32 hashes = _toTypedDataHash(structHash);
        address signer = ecrecover(hashes, v, r, s);
        require(signer == owner, "INVALID_SIGNER");
        approve(owner, spender, value);

    }

    function approve(address _to, uint256 _value) public returns (bool success) {
        //address _from = msg.sender;
        approve(msg.sender, _to, _value);
        return true;
    }

    //function _recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
    //    if (
    //       uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
    //    ) {
    //        revert("ECDSA: invalid signature 's' value");
    //    }
    //
    //   if (v != 27 && v != 28) {
    //        revert("ECDSA: invalid signature 'v' value");
    //    }
    //    address signer = ecrecover(hash, v, r, s);
    //    require(signer != address(0), "ECDSA: invalid signature");
    //    return signer;
    //}   
    //  
    function nonces(address _from) public view returns (uint256) {
       return _nonces[_from];
    }

    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _from, address _to, uint256 _value);
    event Paused ();

}




