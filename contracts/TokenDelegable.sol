pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';



/**
Premier token d'inventaire, disons la money
 */
contract Items is ERC20, Ownable {
    
    address adressDelegateContract;
    uint256 rarity;//0 a 99 999, plus il est haut, moin on a de chance de l'obtenir
    uint256 pricebase;
    uint256 currentprice;

    struct Item {
        string name;
        uint256 rarity;
        uint256 currentPrice;
        uint256 myBalance;
        uint256 allBalance;
    }

    constructor(uint256 _supply,string memory name, string memory symbol) ERC20(name,symbol)  {

    }

    /**
    Foncton très importante que l'ont rajoute sur presque toutes les autres fonctions pour vérifier que l'appel des fonctions ce fais bien depuis le contrat de délégation pour plus de sécuriter
    */
    modifier byDelegate() {
        require((msg.sender == adressDelegateContract || adressDelegateContract == address(0)),"Not good delegate contract");
        _;
    }
    /** 
    modifier l'addresse du contrat de délégation pour permettre aux dit contrat d'intéragir avec celui ci
     */
    function setAdressDelegateContract(address _adress) external onlyOwner {
        adressDelegateContract = _adress;
    }

    function mint(uint256 number, address to) external payable byDelegate {
        _mint(to,number);
    }

    function burn(uint8 number, address to) external byDelegate {
        _burn(to,number);
    }

    function setPrice(uint256 price) external onlyOwner{
        pricebase = price;
    }

    function getPrice() public view returns (uint256){
        return pricebase;
    }

    function setRarity(uint256 rare) external onlyOwner{
        rarity = rare;
    }

    function getRarity() public view returns (uint256){
        return rarity;
    }

    function getBalanceOf(address user) external view returns (uint256){
        return balanceOf(user);
    }

    function getBalanceContract() public view returns (uint256)  {
        return address(this).balance;
    }

    function getName() public view returns (string memory){
        return name();
    }

    function getItemDetails(address myAddress) public view returns (Item memory){
        return Item(getName(),getRarity(),getCurrentPrice(),balanceOf(myAddress),getBalanceContract());
    }


    /*ECONOMY*/

    /**
    achat d'une ressource contre de l'eth/MATIC
     */
    function buyItem(uint256 value, address sender) payable public {
        require(msg.value >= currentprice*value,"More ETH required");
        _mint(sender,value);
        setCurrentPrice();
    }

    /**
    Vente du jeton contre de l'eth/MATIC
     */
    function sellItem(uint256 value, address sender) public {
        require(totalSupply()>value+1,"No more this token");
        require(balanceOf(sender)>=value,"No more this token");
        payable(sender).transfer(currentprice*value);
        _burn(sender,value);
        setCurrentPrice();
    }

    /**
    Vente du jeton contre de l'eth/MATIC
     */
    function convertToAnotherToken(uint256 value,address anotherToken) public {
        /*require(totalSupply()>value+1,"No more this token");
        require(balanceOf(msg.sender)>=value,"No more this token");
        _burn(msg.sender,value);
        currentprice = setCurrentPrice();*/
    }

    function setCurrentPrice() public{
        currentprice = address(this).balance/totalSupply();
    }

    function getCurrentPrice() public view returns (uint256){
        return address(this).balance/totalSupply();
    }

    /*FUNDS OF CONTRACT*/

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        setCurrentPrice();
    }

    function deposit() payable public {
        setCurrentPrice();
    }

    function getBalance() public view returns (uint256)  {
        return address(this).balance;
    }

    //receive() external payable {}


}

contract DelegateContract is Ownable {

    constructor(address _addressContract, address _addressQuestContract, address _addressClassContract) {
        addressContract = _addressContract;
        addressQuestContract = _addressQuestContract;
        addressClassContract = _addressClassContract;
        TokenDelegable contrat = TokenDelegable(addressContract);
        paramsContract["nextId"] = contrat.getParamsContract("nextId");
        paramsContract["price"] = 100000000000000000;//dev:100000000000000000000 == 100 eth
        paramsContract["totalPnt"] = 5;
        paramsContract["tokenLimit"] = 10000;
        paramsContract["nonce"] = 0;
        paramsContract["expForLevelUp"] = 100;
    }

    address addressContract;
    address addressQuestContract;
    address addressClassContract;
    mapping( string => uint ) paramsContract;
    mapping( uint => address ) items;
    uint8 countItems;

    /**
    Mêttre a jour l'addresse de destination du contrat officiel pour que le contrat de délégation puisse y accèder
     */
    function setAddressContract(address _addressContract) external onlyOwner {
        addressContract = _addressContract;
    }

    /**
    Mêttre à jour un paramètre du contrat de délégation
    */
    function setParamsContract(string memory keyParams, uint valueParams) external onlyOwner {
        paramsContract[keyParams] = valueParams;
    }

    /**
    récupérer une valeur du tableau de paramètre du contrat de délégation
    */
    function getParamsContract(string memory keyParams) external view returns (uint256){
        return paramsContract[keyParams];
    }

    /**
    appel vers le contrat officiel du jeton
    Mêttre a jour un paramètre du contrat officiel depuis le contrat de délégation
     */
    function setParamsDelegate(string memory keyParams, uint256 valueParams ) internal {
        TokenDelegable contrat = TokenDelegable(addressContract);
        contrat.setParamsContract(keyParams, valueParams);
    }

    function setAddressItem(address item, uint idItem) external {
        items[idItem] = item;
        countItems++;
    }

    function getAddressItems() external view returns (address[] memory){
        address[] memory result = new address[](countItems);
        uint256 resultIndex = 0;
        uint256 i;
        for(i = 0; i < countItems; i++){
            result[resultIndex] = items[i];
            resultIndex++;
        }
        return result;
    }

    function getAddressItem(uint256 idItem) external view returns (address) {
        return items[idItem];
    }

    function getParamsItem(address addressItem) external view returns (Items.Item memory) {
        Items contratItems = Items(addressItem);
        Items.Item memory itemTemp = contratItems.getItemDetails(msg.sender);
        return itemTemp;
    }

    function getBalanceOfItem(uint256 idItem) external view returns (uint256) {
        Items itemContrat = Items(items[idItem]);
        //return itemContrat.balanceOf(msg.sender);
        return itemContrat.getBalanceOf(msg.sender);
    }
    
    /**
    achat d'une ressource contre de l'eth/MATIC
     */
    function buyItem(address payable addressItem, uint256 value) payable public {
        (bool sent, bytes memory data) = addressItem.call{value: msg.value}(abi.encodeWithSignature("buyItem(uint256,address)", value, msg.sender));
        require(sent, "Failed to send Ether");
    }

    /**
    Vente du jeton contre de l'eth/MATIC
     */
    function sellItem(address addressItem, uint256 value) public {
        Items itemContrat = Items(addressItem);
        itemContrat.sellItem(value,msg.sender);
    }

    

    function depositItem(address addressItem) payable public {
        (bool sent, bytes memory data) = addressItem.call{value: msg.value}(abi.encodeWithSignature("deposit()"));
        require(sent, "Failed to send Ether");
    }

    function getCurrentPrice(address addressItem) public view returns (uint256){
        Items itemContrat = Items(addressItem);
        return itemContrat.getCurrentPrice();
    }

    /**
    appel vers le contrat officiel du jeton
    Offrir un ou plusieurs token a un utilisateur
     */
    function giveToken(address to, uint8 generation) external onlyOwner{
        require(paramsContract["tokenLimit"] > 0,"No remaining");
        bool[] memory booleans = new bool[](20);
        uint8[] memory randomParts = randomParams8(0,0);
        uint256[] memory randomParams = randomParams256(paramsContract["price"],generation);
        paramsContract["nextId"]++;

        TokenDelegable contrat = TokenDelegable(addressContract);
        contrat.mint(to, booleans, randomParts, randomParams);
    }

    /**
    appel vers le contrat officiel du jeton
    Modifier les paramètre d'un token et l'envoyé au contrat de token pour le mêttre a jour
     */
    function mintDelegate(uint8 generation,uint8 peuple,uint8 race) external payable{
        require(msg.value >= paramsContract["price"],"More ETH required");
        require(paramsContract["tokenLimit"] > 0,"No remaining");
        bool[] memory booleans = new bool[](20);
        uint8[] memory randomParts = randomParams8(peuple,race);
        uint256[] memory randomParams = randomParams256(msg.value,generation);
        paramsContract["nextId"]++;

        TokenDelegable contrat = TokenDelegable(addressContract);
        contrat.mint(msg.sender,booleans, randomParts, randomParams);
    }

    /**
    une autre idée pour calculer les stats de départ, ma préféré
     */
    function randomParams8(uint8 peuple, uint8 class) internal virtual returns (uint8[] memory) {
        /*uint256 totalPnt = paramsContract["totalPnt"];
        if(paramsContract["nextId"]<paramsContract["maxFirstGen"]){totalPnt += 3;}else
        if(paramsContract["nextId"]<paramsContract["maxSecondGen"]){totalPnt += 2;}else
        if(paramsContract["nextId"]<paramsContract["maxthirdGen"]){totalPnt += 1;}*/

        uint8[] memory randomParts = new uint8[](20);
        
        ClassesContract classContrat = ClassesContract(addressClassContract);
        uint8[] memory stats = classContrat.getClassStatsDetails(class);

        /*uint8 i;

        while(totalPnt>0){
            if(random(5)>3){
                stats[i]++;
                totalPnt--;
            }
            if(i<stats.length){i++;}else{i=0;}
        }*/

        randomParts[0] = stats[0];//Dex
        randomParts[1] = stats[1];//Str
        randomParts[2] = stats[2];
        randomParts[3] = stats[3];
        randomParts[4] = stats[4];
        randomParts[5] = stats[5];
        //randomParts[6] = 0;//exp
        randomParts[7] = 1;//level
        randomParts[8] = peuple;//peuple
        randomParts[9] = class;//class

        return randomParts;
    }


    function randomParams256(uint256 price, uint8 generation) internal virtual returns (uint256[] memory) {
        uint256[] memory randomParams = new uint256[](10);
        randomParams[0] = block.timestamp;//date de création
        randomParams[1] = price;//prix d'achat
        randomParams[2] = block.timestamp;//date de la dérnière action (il y a une heure) permettant de participer a des missions
        //randomParams[3] = 0;//Mission choisis (si 0 aucune current mission)
        //randomParams[4] = 0;//seconds pour finir la mission
        //randomParams[5] = 0;//difficulté de la quête (détermine l'exp gagné, et les objets % gagné)
        randomParams[6] = paramsContract["nextId"];//tokenId
        randomParams[7] = generation;//type
        return randomParams;
    }

    function startQuest(uint256 tokenId, uint256 questId) public {
        TokenDelegable contrat = TokenDelegable(addressContract);
        require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
        /*QuestContract questContrat = QuestContract(addressQuestContract);
        QuestContract.Quest memory questTemp =  questContrat.getQuestDetails(questId);
        require(questTemp.valid == true,"Quest not exist");*/
        TokenDelegable.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
        require(tokenTemp.params256[3] == 0, "Quest not finished");
        tokenTemp.params256[3] = questId;
        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }

    /**
    Validation de la quête a la fin du comteur time d'une quest
     */
    function completeQuest(uint256 tokenId) public {
        TokenDelegable contrat = TokenDelegable(addressContract);
        require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
        TokenDelegable.Token memory tokenTemp =  contrat.getTokenDetails(tokenId);
        
        QuestContract questContrat = QuestContract(addressQuestContract);
        QuestContract.Quest memory questTemp = questContrat.getQuestDetails(tokenTemp.params256[3]);
        require(block.timestamp-tokenTemp.params256[2] > (questTemp.time), "Quest not finished");//BON CA VA PAS REVISER COMPLEMENT LE TIME ET COTER FRONT AUSSI
        //require(block.timestamp > tokenTemp.params256[2]+(questTemp.time), "Quest not finished");//ça fonctionnais mais celle du dessus est surement plus propre 
        uint8 malus = 0;
        for (uint8 index = 0; index < questTemp.stats.length; index++) {
            if(questTemp.stats[index] > tokenTemp.params8[index]){
                malus += questTemp.stats[index]-tokenTemp.params8[index];
            }
        }
        if(random(100-malus)>questTemp.percentDifficulty){
            tokenTemp.params8[6] += questTemp.exp*questContrat.getMultiplicateurExp();

            for (uint index = 0; index < countItems; index++) {
                Items itemtemp = Items(items[index]);
                if(random256(100000)>itemtemp.getRarity()){
                    itemtemp.mint(1,msg.sender);
                }
            }
        }
        tokenTemp.params256[2] = block.timestamp;
        tokenTemp.params256[3] = 0;
        tokenTemp.params256[4] = 0;

        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }

    function getQuest(uint8 questId) external view returns (QuestContract.Quest memory){
        QuestContract contrat = QuestContract(addressQuestContract);
        QuestContract.Quest memory questTemp =  contrat.getQuestDetails(questId);
        return questTemp;
    }

    /**
    Quand l'exp est a fond, luser peut rajouter un point ou il veux
    Réfléchir a la logique d'exp max, pour l'instant (100+(?**level))
    Est ce qu'ont rajouterai pas de façon random des points autres part
    */
    function levelUp(uint8 statToLvlUp, uint256 tokenId) public{
        TokenDelegable contrat = TokenDelegable(addressContract);
        require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
        TokenDelegable.Token memory tokenTemp =  contrat.getTokenDetails(tokenId);
        require(tokenTemp.params8[6]>(100+(paramsContract["expForLevelUp"]**tokenTemp.params8[7])),"experience not enought");
        tokenTemp.params8[statToLvlUp] ++;
        tokenTemp.params8[6] = 0;
        tokenTemp.params8[7]++;

        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }


    /**
    a finaliser
     */
    /*function calculPriceSupply() public{
        TokenDelegable contrat = TokenDelegable(addressContract);
        uint totalSupply = contrat.getParamsContract("totalSupply");
        //priceInUsd = (item.price/(10**18)) * (latestPrice/10**8)
    }*/

    
    /**
    appel vers le contrat officiel du jeton
    Modifier les paramètre d'un token et l'envoyé au contrat de token pour le mêttre a jour
     */
    /*function paramsToken(uint256 tokenId,bool[] memory booleans, uint8[] memory params8, uint256[] memory params256) external {
        
        TokenDelegable contrat = TokenDelegable(addressContract);
        TokenDelegable.Token memory tokenTemp =  contrat.getTokenDetails(tokenId);
        //if(tokenTemp.params256[2] != params256[2]) tokenTemp.params256[0] = block.timestamp;//mettre a jour la date de création si besoin
        for (uint8 index = 0; index < booleans.length; index++) {
            tokenTemp.booleans[index] = booleans[index];
        }
        for (uint8 index = 0; index < params8.length; index++) {
            tokenTemp.params8[index] = params8[index];
        }
        for (uint8 index = 0; index < params256.length; index++) {
            tokenTemp.params256[index] = params256[index];
        }
        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }*/

    
    /**
    appel vers le contrat officiel du jeton
    transfert d'un token d'un propriétaire a un autre adresse
     */
    function transfer(address contactAddr, uint256 tokenId) external payable {
        TokenDelegable contrat = TokenDelegable(addressContract);
        require(contrat.getOwnerOf(tokenId) != msg.sender, "Not your token");
        contrat.transfer(contactAddr, msg.sender, tokenId);
    }

    
    /**
    appel vers le contrat officiel du jeton
    Achat d'un token par un utilisateur
     */
    function purchase(address contactAddr, uint256 tokenId) external payable {//vendre que des oeufs
        TokenDelegable contrat = TokenDelegable(addressContract);
        TokenDelegable.Token memory token = contrat.getTokenDetails(tokenId);
        require(msg.value >= token.params256[1], "Insufficient fonds sent");
        require(contrat.getOwnerOf(tokenId) != msg.sender, "Already Owned");
        //contrat.updateToken(token,tokenId,msg.sender);
        contrat.transfer(contactAddr, msg.sender, tokenId);
    }

    
    /**
    appel vers le contrat officiel du jeton
    récupérer un tableau d'id des tokens d'un utilisateur
     */
    function getAllTokensForUser(address user) external view returns (uint256[] memory){
        TokenDelegable contrat = TokenDelegable(addressContract);
        return contrat.getAllTokensForUser(user);
    }
    
    /**
    appel vers le contrat officiel du jeton
    récupérer les data d'un token avec son id
     */
    function getTokenDetails(uint256 tokenId) external view returns (TokenDelegable.Token memory){
        TokenDelegable contrat = TokenDelegable(addressContract);
        return contrat.getTokenDetails(tokenId);
    }

    function random(uint8 maxNumber) internal returns (uint8) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, paramsContract["nonce"]))) % maxNumber;
        paramsContract["nonce"]++;
        return uint8(randomnumber);
    }

    function random256(uint256 maxNumber) internal returns (uint256) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, paramsContract["nonce"]))) % maxNumber;
        paramsContract["nonce"]++;
        return randomnumber;
    }

    /*FUNDS OF CONTRACT*/

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit() payable public onlyOwner {
    }

    function getBalance() public view returns (uint256)  {
        return address(this).balance;
    }

}


contract QuestContract is Ownable {
    /**
    Pour les quetes pas d'obligation de stat
    On défini le taux de réussite de 0 a 100 %
    Quetes avec recommandation de stats (exemple 20 de force) si en dessous de 20 on retire le manque aux % de chance de reussite de 0 a 100 %
    Si plus aucune différence de réussite
    */
    struct Quest {
        uint8 exp;
        uint8 percentDifficulty;//0 a 100
        uint8[] stats;//required
        uint256 id;
        uint256 time;
        bool valid;
    }

    constructor(){
        multiplicateurExp = 1;
    }

    mapping( uint256 => Quest ) private _questDetails;

    uint8 questCount;
    uint8 multiplicateurExp;

    
    /* QUEST */
    function setQuest(uint256 id, uint256 time, uint8 exp, uint8 percentDifficulty, uint8[] memory stats) public onlyOwner {
        if(_questDetails[id].valid==false)questCount++;
        _questDetails[id] = Quest(exp,percentDifficulty,stats,id,time,true);
    }

    function removeQuest(uint256 id) public onlyOwner {
        if(_questDetails[id].valid==true)questCount--;
        _questDetails[id].valid = false;
    }

    function getQuestDetails(uint256 questId) external view returns (Quest memory){
        //require(_questDetails[questId],"Quest not exist");
        return _questDetails[questId];
    }

    function getMultiplicateurExp() external view returns (uint8){
        //require(_questDetails[questId],"Quest not exist");
        return multiplicateurExp;
    }

    /**
    Récupérer dans un tableau tout les id token d'un utilisateur
    */
    function getAllQuests() external view returns (uint256[] memory){
        uint[] memory result = new uint256[](questCount);
        uint256 resultIndex = 0;
        uint256 i;
        for(i = 0; i < questCount; i++){
            result[resultIndex] = _questDetails[i].id;
            resultIndex++;
        }
        return result;
    }
}

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


contract TokenDelegable is ERC721Enumerable, Ownable {
    using Strings for uint256;
    
    struct Token {
        bool[] booleans;
        uint8[] params8;//parts 
        uint256[] params256;//params
    }


    address adressDelegateContract;
    mapping( string => uint ) paramsContract;
    mapping( uint256 => Token ) private _tokenDetails;
    
    string public baseURI;
    string public baseExtension = ".json";
    bool public paused = false;

    constructor(string memory name, string memory symbol, string memory _initBaseURI) ERC721(name, symbol){
        paramsContract["nextId"] = 0;
        paramsContract["totalSupply"] = 0;
        setBaseURI(_initBaseURI);
    }

    function random(uint8 maxNumber) internal returns (uint8) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, paramsContract["nonce"]))) % maxNumber;
        paramsContract["nonce"]++;
        return uint8(randomnumber);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require( _exists(tokenId), "ERC721Metadata: URI query for nonexistent token" );
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }

    /**
    Foncton très importante que l'ont rajoute sur presque toutes les autres fonctions pour vérifier que l'appel des fonctions ce fais bien depuis le contrat de délégation pour plus de sécuriter
    */
    modifier byDelegate() {
        require((msg.sender == adressDelegateContract || adressDelegateContract == address(0))&& !paused,"Not good delegate contract");
        _;
    }

    /**
    Mêttre en pause le contrat en cas de problème
     */
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    /**
    Fonction de mint, on envoi un tableau de uint8 et un tableau de uint256 qui seront les params de notre token
    On enregistre la struct dans un mapping avec la key id
    Puis on mint avec la même key id
    */
    function mint(address sender, bool[] memory booleans, uint8[] memory params8, uint256[] memory params256) external payable byDelegate {
        _tokenDetails[paramsContract["nextId"]] = Token(booleans,params8,params256);
        _safeMint(sender, paramsContract["nextId"]);
        paramsContract["nextId"]++;
        paramsContract["totalSupply"]++;
    }
    
    /**
    Burn un token avec son id et diminué le total supply
    */
    function burn(uint256 tokenId) external byDelegate {
        _burn(tokenId);
        paramsContract["totalSupply"]--;
    }

    /*
    Transféré un token d'une adresse à une autre en utilsant l'id token
    */
    function transfer(address from, address to ,uint256 tokenId) external byDelegate {
        _safeTransfer(from, to, tokenId, "");
    }
    
    /**
    Récupérer dans un tableau tout les id token d'un utilisateur
    */
    function getAllTokensForUser(address user) external view returns (uint256[] memory){
        uint256 tokenCount = balanceOf(user);
        if(tokenCount == 0){
            return new uint256[](0);
        }
        else{
            uint[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = paramsContract["nextId"];
            uint256 resultIndex = 0;
            uint256 i;
            for(i = 0; i < totalTokens; i++){
                if(ownerOf(i) == user){
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }

    /**
    Récupérer l'adresse du possesseur du token en utilisant la key id du token
    */
    function getOwnerOf(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }

    /**
    Récupérer le nombre de token possédé par un joueur
     */
    function getBalanceOf(address user) external view returns (uint) {
        return balanceOf(user);
    }

    /**
    Mêttre a jour le Token (hero) en utilisant l'id en clé et en envoyant directement l'objet de la mise a jour du token
     */
    function updateToken(Token memory tokenTemp,uint256 tokenId,address owner) external byDelegate {
        require(ownerOf(tokenId) == owner,"Not Your token");
        _tokenDetails[tokenId] = tokenTemp;
    }
    
    /**
    Récupérer les datas d'un token en utilisant son id
     */
    function getTokenDetails(uint256 tokenId) external view returns (Token memory){
        return _tokenDetails[tokenId];
    }

    /**
    Mêttre a jour une des datas du cotnrat en utilisant la key
     */
    function setParamsContract(string memory keyParams, uint valueParams) external onlyOwner {
        paramsContract[keyParams] = valueParams;
    }

    /**
    Récuperer une des datas du contrat en utilisant la key
     */
    function getParamsContract(string memory keyParams) external view returns (uint){
        return paramsContract[keyParams];
    }

    /** 
    modifier l'addresse du contrat de délégation pour permettre aux dit contrat d'intéragir avec celui ci
     */
    function setAdressDelegateContract(address _adress) external onlyOwner {
        adressDelegateContract = _adress;
    }

    /*FUNDS OF CONTRACT*/

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit() payable public onlyOwner {
    }

    function getBalance() public view returns (uint256)  {
        return address(this).balance;
    }

}


/*Tout faire passer par le contrat pour permettre :
-plus de sécurité, quasi incraquable
-aucun moyen que le serveur tombe a un moment et que les joueurs soit en panique
-tracabilité et transparance maximum, ont peut voir quels actions ont était effectué par qui et a quel moment

L'avantage de faire de chaque items un jeton ERC20 :
-Transmition facile d'un user à un autre, ou d'un contrat à un autre
-Impossible de craquer le jeu et ce donner des millions d'item, en gros triche impossible
-Vente des jetons facile
-Petit icone sur meta mask pour son jeton ça rajoute toujours une sorte d'attachement au jeton*/