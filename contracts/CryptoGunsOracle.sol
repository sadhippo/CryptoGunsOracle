// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./safemath32.sol";
import "./ERC20Interface.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";



contract CryptoGunsOracle is AccessControlUpgradeable, ERC721URIStorageUpgradeable,EIP712Upgradeable, OwnableUpgradeable{
  using SafeMath32 for uint32;
  using SafeMathUpgradeable for uint256;

  struct Swat {
    string name;
    bool upgraded;
    uint upgradeCount;
    uint skinIndex;
//    uint32 readyTime;
  }
  struct Claim{
    uint claimId;
  }


//Events
event NewSwat(address indexed _player, uint _swatId, string _name);
event Burn(address indexed _player, uint256 _swatId);
event SwatPriceSet(uint newPrice);
event Purchased(address indexed _receivingPlayer);
event TokenWithdrawal(uint _amount);
event VoucherRedeemed(address indexed _receivingPlayer, string _name);



//Mappings
mapping(address => uint[]) public userOwnedSwats; //tokenID of swat units in wallet
mapping(uint => uint) public swatIsAtIndex; // index of the tokenID in the wallet
mapping (address => uint) public ownerSwatCount; //# of swat units in wallet
//VRF MAPPINGS
mapping(bytes32 => address) requestToSender;
mapping(bytes32 => uint256) requestToTokenId;

// Access Control Roles
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 public constant SUPER_MINTER_ROLE = keccak256("SUPER_MINTER_ROLE");

//Variables
Swat[] public swats;

//VRF VARIABLES
bytes32 internal keyHash;
uint256 internal fee;

//uint256 public roll;

string private SIGNING_DOMAIN;
 string private SIGNATURE_VERSION;

uint public swatPrice; // in banana
//uint public cooldownTime;
uint nonce;
ERC20Interface public acceptedToken;
address public _acceptedToken;

Claim[] public claims;

 //VRF FUNCTION
 // /**
 //     * initialize inherits VRFConsumerBase
 //     *
 //     * Network: Binance Smart Chain Testnet
 //     * Chainlink VRF Coordinator address: 0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31
 //     * LINK token address:                0x404460C6A5EdE2D891e8297795264fDe62ADBB75
 //     * Key Hash: 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c
 //     * Fee: .2
 //     */
function initialize() public initializer {
  // VRF PARAMs address _VRFCoordinator, address _LinkToken,  bytes32 _keyhash
     __ERC721_init("CryptoGuns Squad Members", "SquadMembers");
     __AccessControl_init();
     __ERC721URIStorage_init();
      SIGNING_DOMAIN = "CryptoGuns-Voucher";
       SIGNATURE_VERSION = "1";
     __EIP712_init(SIGNING_DOMAIN, SIGNATURE_VERSION);
     __Ownable_init();
     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
     _setupRole(MINTER_ROLE, _msgSender());
     _setupRole(SUPER_MINTER_ROLE, _msgSender());

         // we made a test simple token for testnet. - 0x0C69F8B5133038D445d9dc9CA53a0061FE260Ea6
     _acceptedToken = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;
      nonce = 0;
      acceptedToken = ERC20Interface(_acceptedToken);

}

  function _baseURI() internal pure override returns (string memory) {
    return "https://www.cryptoguns.io/json/";
  }

function addAdmin(address account) public virtual {
  require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
  grantRole(DEFAULT_ADMIN_ROLE, account);
 }
 function addMinter(address account) public virtual {
   require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
   grantRole(MINTER_ROLE, account);
  }

  function addSuperMinter(address account) public virtual {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
    grantRole(SUPER_MINTER_ROLE, account);
   }



//assigns URI to swat based on name. Unity Engine reads the URI to pull character attributes for in-game stats.
  function _mintSwat(string memory _name,address _owner) internal {

    swats.push(Swat(_name, false, 0, 0));
    uint id = swats.length - 1;
    ownerSwatCount[_owner] = ownerSwatCount[_owner] + 1;
    userOwnedSwats[_owner].push(id);
    uint ownedSwatLength = userOwnedSwats[_owner].length;
    swatIsAtIndex[id] = ownedSwatLength -1;
    _safeMint(_owner, id);
    emit NewSwat( _msgSender(), id, _name);
    bytes32 swatName = keccak256(abi.encodePacked(_name));
    if(swatName == keccak256("jason")){
      _setTokenURI(id, _name);
    }
      else if(swatName == keccak256("discipliner")){
      _setTokenURI(id,_name);
    }
    else if(swatName == keccak256("nightmare")){
      _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("sarge")){
         _setTokenURI(id, _name);
       }
       else if(swatName == keccak256("mastersee")){
         _setTokenURI(id, _name);
       }
       else if(swatName == keccak256("loki")){
         _setTokenURI(id, _name);
       }
          else if(swatName == keccak256("jaguar")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("pistolpete")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("freya")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("eagleeye")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("rumple")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("terrorrick")){
      _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("pump")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("action")){
        _setTokenURI(id, _name);
      }
        else if(swatName == keccak256("jimrimbo")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("keithurban")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("steve")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("woodsie")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("phil")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("basicbob")){
        _setTokenURI(id, _name);
     }
    }

  // function _randomRoll() internal returns (uint) {
  //   uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, _msgSender(), nonce))) % 1000;
  //   nonce++;
  //   return randomnumber;
  // }
//
// VRF Function
// function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
//
  //function mintRandomSwat(address _owner) public {

  function randRoll() internal returns(uint)
  {
     // increase nonce
     nonce++;
     uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp,
                                            msg.sender,
                                            nonce)));
    return randomNumber;
   }

  function mintRandomSwat(address _player) public  {
    string memory randName;
    string memory randName2;
    string memory randName3;
    string memory randName4;
    string memory randName5;
    uint roll;
      uint roll2;
        uint roll3;
          uint roll4;
            uint roll5;

    uint randomness = randRoll();
    // .2% for mythic, .7% for legendary, 10% for rare, 35% uncommon, rest Common
    roll = (randomness % 1000) + 1;
    roll2 = ((randomness / 1000) % 1000) + 1;
    roll3 =((randomness / 1000000) % 1000) + 1;
    roll4 = ((randomness / 1000000000) % 1000) + 1;
    roll5 =((randomness / 1000000000000) % 1000) + 1;

    randName = rollToName(roll);
    randName2 = rollToName(roll2);
    randName3 = rollToName(roll3);
    randName4 = rollToName(roll4);
    randName5 = rollToName(roll5);

  _mintSwat(randName, _player);
  // _mintSwat(randName2, _player);
  // _mintSwat(randName3, _player);
  // _mintSwat(randName4, _player);
  // _mintSwat(randName5, _player);

}

function rollToName(uint roll) internal pure returns (string memory){
  string memory randName;

      if(roll >= 998) {
        randName = "jasonlake";
      }
      else if(roll >= 996)
        {randName = "discipliner";
        }
      else if(roll > 994)
        {randName = "nightmare";
        }

      else if(roll > 991){
        randName = "sarge";
      }
      else if(roll > 987){
        randName = "mastersee";
      }
      else if(roll > 984){
        randName = "loki";
    }

      else if(roll > 950){
        randName = "jaguar";
      }
      else if(roll > 930){
        randName = "pistolpete";
      }
      else if(roll > 910){
        randName = "freya";
      }
      else if(roll > 890){
        randName = "eagleeye";
      }
      else if(roll > 870){
        randName = "rumple";
        }
      else if(roll > 850){
        randName = "terrorrick";
      }

      else if(roll > 750)
        {randName = "pump";
      }
      else if(roll > 650)
        {randName = "action";
        }
      else if(roll > 500){
        randName = "jimrimbo";
        }

      else if(roll > 400){
        randName = "keithurban";
      }
      else if(roll > 300){
        randName = "steve";
       }
      else if(roll > 200){
        randName = "woodsie";
       }
      else if(roll > 100){
        randName = "phil";
     }
      else {
        randName = "basicbob";
         }
         return randName;
}

//for rewards
function mintSpecificSwat(address _owner, string memory _name) public {
  hasRole(MINTER_ROLE, _msgSender());
 _mintSwat(_name, _owner);
}


function mintSpecificSquad(address _owner, string memory _name, string memory _name2, string memory _name3, string memory _name4, string memory _name5 ) public {
  hasRole(SUPER_MINTER_ROLE, _msgSender());
 _mintSwat(_name, _owner);
 _mintSwat(_name2, _owner);
 _mintSwat(_name3, _owner);
 _mintSwat(_name4, _owner);
 _mintSwat(_name5, _owner);
}

function bulkMintSquad(address _owner, string[] memory _names) public {
  hasRole(SUPER_MINTER_ROLE, _msgSender());

  for(uint i = 0; i < _names.length; i++ ){
    string memory name = _names[i];
    _mintSwat( name , _owner);
  }
}



//if owner has duplicates, can burn one to turn the first into "upgraded"
function duplicateUpgrade(uint _swatId, uint _targetId) public{
   require(_exists(_swatId), "token id not recognized");
   require(_exists(_targetId), "token id not recognized");
   require(ownerOf(_swatId) == _msgSender(), "not the owner");
   require(ownerOf(_targetId) == _msgSender(), "not the owner");

  Swat storage mySwat = swats[_swatId];
  Swat storage mySwat2 = swats[_targetId];
  require(mySwat.upgradeCount < 5);
  require((keccak256(abi.encodePacked(mySwat.name))) == (keccak256(abi.encodePacked(mySwat2.name))), "can only upgrade similar units");
  if(mySwat.upgraded == false){
  mySwat.upgraded = true;
}
  mySwat.upgradeCount = mySwat.upgradeCount + 1;
  _burn(_targetId);
  emit Burn(_msgSender(), _targetId);
  //_triggerCooldown(mySwat);

}

//if owner has duplicates, can burn one to turn the first into "upgraded"
function upgradeSkin(uint _swatId, uint _targetId, uint _skinId) public{
   require(_exists(_swatId), "token id not recognized");
   require(_exists(_targetId), "token id not recognized");
   require(ownerOf(_swatId) == _msgSender(), "not the owner");
   require(ownerOf(_targetId) == _msgSender(), "not the owner");

  Swat storage mySwat = swats[_swatId];
  Swat storage mySwat2 = swats[_targetId];
  require((keccak256(abi.encodePacked(mySwat.name))) == (keccak256(abi.encodePacked(mySwat2.name))), "can only use similar units");
  mySwat.skinIndex = _skinId;
  _burn(_targetId);
  emit Burn(_msgSender(), _targetId);
  //_triggerCooldown(mySwat);

}



//overrides duplicate functions begins here
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
          return super.supportsInterface(interfaceId);

        }

  function  _burn(uint256 tokenId) internal virtual override(ERC721URIStorageUpgradeable) {
          uint256 index = swatIsAtIndex[tokenId];
        ownerSwatCount[_msgSender()] = ownerSwatCount[_msgSender()] - 1;
         delete userOwnedSwats[_msgSender()][index];
         //swatIsAtIndex[tokenId] = -1;
          return super._burn(tokenId);
  }

  function burnNFT(uint256 _swatId) public{
    require(ownerOf(_swatId) == _msgSender(), "not the owner");
    _burn(_swatId);
      emit Burn(_msgSender(), _swatId);
  }


//removes the unit from the owner's swat count. then it adds the unit to the recievers swat count and it updates the swatIndex to it's position in the recievers wallet.
// then it sets the mapping userOwnedSwats to an outrageously high number that we tell the front-end to ignore on load.
  function  _transfer(address _from, address _to, uint256 _tokenId) internal virtual override {

            uint256 index = swatIsAtIndex[_tokenId];
            //update mappings
          ownerSwatCount[_from] -= 1;
          ownerSwatCount[_to] += 1;
          userOwnedSwats[_to].push(_tokenId);
          uint256 toOwnedSwatLength = userOwnedSwats[_to].length;
          swatIsAtIndex[_tokenId] = toOwnedSwatLength - 1;
          userOwnedSwats[_from][index] = 999999;

          return super._transfer(_from, _to, _tokenId);
  }
//ERC721Upgradeable
  function tokenURI(uint256 tokenId) public view virtual override (ERC721URIStorageUpgradeable) returns (string memory) {
          return super.tokenURI(tokenId);
  }


  // function buyNFT(address _buyer) public {
  //   require(_msgSender() == _buyer, "");
  //   require(acceptedToken.transferFrom(_msgSender(), address(this), swatPrice), "");
  //   mintRandomSwat(_buyer);
  //
  //   emit Purchased(_buyer);
  //     }
  //
      function setSwatPrice(uint256 _price) public {
         require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "");
      //  require(_price > 1, "");
        //require(_price !< 20 * (10**18), "");
        swatPrice = _price;

        emit SwatPriceSet(_price);
      }

      function getSwatPrice() public view returns (uint256) {
          return swatPrice;
      }


      function withdrawToken (uint _amount) external{
      require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "");
      require(acceptedToken.transfer(_msgSender(), _amount), "");
      emit TokenWithdrawal(_amount);
      }

      function getSwatName(uint _swatId) public view returns (string memory) {
        return swats[_swatId].name;
      }

      function getSwatLength() public view returns (uint){
        uint256 length = swats.length;
        return length;
      }

      function getClaimLength() public view returns(uint){
        uint256 length = claims.length;
        return length;
      }

      // function getReadyTime(uint _swatId) public view returns (uint) {
      //   return swats[_swatId].readyTime;
      // }

      function getUpgraded(uint32 _swatId) public view returns (bool) {
        return swats[_swatId].upgraded;
      }

      function getUpgradeCount(uint32 _swatId) public view returns (uint) {
        return swats[_swatId].upgradeCount;
      }

      function getSkinIndex(uint32 _swatId) public view returns (uint) {
        return swats[_swatId].skinIndex;
      }




      // function _triggerCooldown(Swat storage _swat) internal {
      //   _swat.readyTime = uint32(block.timestamp + cooldownTime);
      // }
      //
      // function _isReady(Swat memory _swat) public view returns (bool) {
      //     return (_swat.readyTime <= block.timestamp);
      // }

      function getSwatsOwnedBy(address _owner) public view returns (uint){
      //  uint SwatCount = ownerSwatCount[_owner];
      return ownerSwatCount[_owner];
      }

      function getSwatIndex(uint _id) public view returns (uint){
      //uint SwatIndex = swatIsAtIndex[_id];
      return  swatIsAtIndex[_id];
      }



      function redeemReward(address player, string memory name, uint256 claimId, bytes memory signature)
         external
         {
           require(_msgSender() == player, "This isn't yours!");
           require(isValidSignature(player, name, claimId, signature), "You have no power here!");
           //require(_exists(tokenId) == false, "this token already exists");
           require(claimId == claims.length, "claimId invalid");
           claims.push(Claim(claimId));
              _mintSwat(name, player);

              emit VoucherRedeemed(player, name);

         }

         function getChainID() external view returns (uint256) {
           uint256 id;
           assembly {
               id := chainid()
           }
           return id;
         }

         // helper function that returns a boolean
           function isValidSignature(address player, string memory name, uint256 claimId, bytes memory signature)
               internal
               view
               returns (bool)
           {
               // convert the payload to a 32 byte hash
               bytes32 hash = ECDSAUpgradeable.toEthSignedMessageHash(keccak256(abi.encodePacked(player, name, claimId)));

               // check that the signature is from MINTER_ROLE
               return hasRole(MINTER_ROLE, ECDSAUpgradeable.recover(hash, signature));
           }

}
