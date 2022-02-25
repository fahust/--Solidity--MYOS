pragma solidity 0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';


contract ClassesContract is Ownable {
    
    struct Classes {
        uint8[] stats;//required
        uint256 id;
        bool valid;
        string name;
    }

    mapping( uint8 => Classes ) private _classDetails;
    
    uint8 classCount;

    /*CLASSE*/
    function setClass(uint8 id, uint8[] memory stats, string memory name) public onlyOwner {
        if(_classDetails[id].valid==false)classCount++;
        _classDetails[id] = Classes(stats,id,true,name);
    }

    function removeClass(uint8 id) public onlyOwner {
        if(_classDetails[id].valid==true)classCount--;
        _classDetails[id].valid = false;
    }

    function getClassStatsDetails(uint8 classId) external view returns (uint8[] memory){
        return _classDetails[classId].stats;
    }

    function getClassDetails(uint8 classId) external view returns (Classes memory){
        return _classDetails[classId];
    }

    /**
    Récupérer dans un tableau tout les id token d'un utilisateur
    */
    function getAllClass() external view returns (uint256[] memory){
        uint[] memory result = new uint256[](classCount);
        uint256 resultIndex = 0;
        for(uint8 i = 0; i < classCount; i++){
            result[resultIndex] = _classDetails[i].id;
            resultIndex++;
        }
        return result;
    }

}

