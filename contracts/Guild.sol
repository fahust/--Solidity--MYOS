// SPDX-License-Identifier: MIT
// Guild contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Guild is ERC20 {
    struct Member {
        bool valid;
        uint8 grade;
        uint256 createdAt;
        uint256 chestETH;
        address addBy;
        address addressMember;
    }

    struct Invit {
        bool valid;
        address addr;
        string description;
    }

    struct Grade {
        bool valid;
        bool write;
        bool read;
        bool invit;
        bool desinvit;
        bool sendMoney;
        bool takeMoney;
        bool graduate;
        string name;
    }

    mapping(uint8 => Grade) _grades;
    mapping(uint256 => Member) _members;
    mapping(uint256 => Invit) _invits;
    uint256 id;
    uint256 nonceMember;
    uint256 countMember;
    uint256 countInvit;
    address payable owner;
    address myosAddress;

    constructor(
        string memory name,
        string memory symbol,
        address payable _owner,
        address _myosAddress,
        uint256 _id
    ) ERC20(name, symbol) {
        owner = _owner;
        myosAddress = _myosAddress;
        id = _id;
    }

    modifier onlyCreator() {
        require(
            msg.sender == owner || msg.sender == myosAddress,
            "Not your guild"
        );
        _;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function setGrade(
        uint8 _id,
        bool valid,
        bool write,
        bool read,
        bool invit,
        bool desinvit,
        bool sendMoney,
        bool takeMoney,
        bool graduate,
        string memory name
    ) external onlyCreator {
        require(_id > 0 && _id < 10, "10 Grade Max");
        _grades[_id] = Grade(
            valid,
            write,
            read,
            invit,
            desinvit,
            sendMoney,
            takeMoney,
            graduate,
            name
        );
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function getGrade(uint8 _id) external view returns (Grade memory) {
        return _grades[_id];
    }

    /**
    SUBSCRIBE SECTION
     */
    function suscribe(string memory description) external {
        _invits[countInvit] = Invit(true, msg.sender, description);
        countInvit++;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function unsuscribe(uint256 invit) external {
        require(
            _invits[invit].valid == true,
            "This invitation is no more valid"
        );
        uint256 changerId;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == msg.sender) changerId = index;
        }
        require(
            _invits[invit].addr == msg.sender ||
                (_members[changerId].valid == true &&
                    _grades[_members[changerId].grade].desinvit == true),
            "Your are not authorized to do this"
        );
        _invits[invit].valid = false;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function getOneSubscription(uint256 invit)
        external
        view
        returns (Invit memory)
    {
        require(
            _invits[invit].valid == true,
            "This invitation is no more valid"
        );
        return _invits[invit];
    }

    /*function getAllSubscription() external view returns (uint256[] memory){
        if(countInvit == 0){
            return new uint256[](0);
        }
        else{
            uint[] memory result = new uint256[](countInvit);
            uint256 resultIndex = 0;
            for(uint256 i = 0; i < countInvit; i++){
                if(_invits[i].valid == true){
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }*/

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function getAllSubscriptionStruct() external view returns (Invit[] memory) {
        if (countInvit == 0) {
            return new Invit[](0);
        } else {
            Invit[] memory result = new Invit[](countInvit);
            for (uint256 i = 0; i < countInvit; i++) {
                if (_invits[i].valid == true) {
                    Invit storage invit = _invits[i];
                    result[i] = invit;
                }
            }
            return result;
        }
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function addMember(address _to) external {
        uint256 changerId;
        uint256 changedId;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == msg.sender) changerId = index;
        }
        for (uint256 index2 = 0; index2 < countInvit; index2++) {
            if (_invits[index2].addr == _to) changedId = index2;
        }
        require(_members[changedId].valid == true, "User not valid");
        require(
            _members[changerId].valid == true &&
                _grades[_members[changerId].grade].invit == true,
            "Your are not authorized to do this"
        );
        _members[nonceMember] = Member(
            false,
            0,
            block.timestamp,
            0,
            msg.sender,
            _to
        );
        _members[changedId].valid = false;
        nonceMember++;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function changeGrade(address _to, uint8 grade) external {
        uint256 changerId;
        uint256 changedId;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == msg.sender) changerId = index;
            if (_members[index].addressMember == _to) changedId = index;
        }
        require(
            _grades[_members[changerId].grade].graduate == true ||
                msg.sender == owner ||
                msg.sender == myosAddress,
            "Your rank does not authorize upgrading"
        );
        require(
            (_members[changerId].grade >= grade &&
                _members[changerId].grade > _members[changedId].grade) ||
                msg.sender == owner ||
                msg.sender == myosAddress,
            "Your rank is not high enough"
        );
        require(
            _members[changedId].valid == true &&
                _members[changerId].valid == true,
            "Not valid user"
        );
        _members[changerId].grade = grade;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
    on ban un membre de la guild tout en gardant ses informations juste en le passant en invalid
    mais on lui rend sa thune quand même on est pas des sauvages
     */
    function subMember(address _to) external {
        uint256 changerId;
        uint256 changedId;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == msg.sender) changerId = index;
            if (_members[index].addressMember == _to) changedId = index;
        }

        require(
            _grades[_members[changerId].grade].desinvit == true ||
                msg.sender == owner ||
                msg.sender == myosAddress,
            "Your rank does not authorize upgrading"
        );
        require(
            _members[changerId].grade > _members[changedId].grade ||
                msg.sender == owner ||
                msg.sender == myosAddress,
            "Your rank is not high enough"
        );
        require(
            _members[changedId].valid == true &&
                _members[changerId].valid == true,
            "Not valid user"
        );
        payable(_members[changedId].addressMember).transfer(
            _members[changedId].chestETH
        );
        _members[changedId].valid = false;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function getAllMembers() external view returns (Member[] memory) {
        if (countMember == 0) {
            return new Member[](0);
        } else {
            Member[] memory result = new Member[](countMember);
            for (uint256 i = 0; i < countMember; i++) {
                if (_members[i].valid == true) {
                    Member storage member = _members[i];
                    result[i] = member;
                }
            }
            return result;
        }
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function getOneMember(address user) external view returns (Member memory) {
        Member memory tempMember;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == user)
                tempMember = _members[index];
        }
        return tempMember;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
     */
    function validMember(bool valid, uint256 member) external onlyCreator {
        _members[member].valid = valid;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
    Déposer de l'argent sur le contrat accéssible seulement pour l'utilisateur
     */
    function sendETHInChest() external payable {
        uint256 idUser;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == msg.sender) idUser = index;
        }
        require(_members[idUser].valid == true, "Not valid user");
        _members[idUser].chestETH += msg.value;
    }

    /**
    appel direct depuis web3 (on ne passe pas par delegate contract)
    Récupérer l'argent de l'utilisateur posé précédement sur le contrat
     */
    function withdrawETHMyChest(uint256 value) external {
        uint256 idUser;
        for (uint256 index = 0; index < countMember; index++) {
            if (_members[index].addressMember == msg.sender) idUser = index;
        }
        require(_members[idUser].valid == true, "Not valid user");
        require(
            _members[idUser].chestETH >= value,
            "Not enougth ether in chest"
        );
        payable(msg.sender).transfer(value);
    }

    /**
    appel depuis le delegate contract on devrais en fait ne pas faire ça parce que trop risquer pour les users
     */
    function kill() external onlyCreator {
        selfdestruct(owner);
    }

    function getId() external view returns (uint256) {
        return id;
    }

    function isOwner(address _owner) external view returns (bool) {
        return _owner == owner;
    }
}
