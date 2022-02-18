pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';



/**
Premier token d'inventaire, disons la money
 */
contract Credit is ERC20, Ownable {
    
    address adressDelegateContract;

    constructor(uint256 _supply) ERC20("MYOS CREDIT","MYOS_CRDT"){

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

    function mint(uint256 number, address to) external byDelegate {
        _mint(to,number);
    }

    function burn(uint8 number, address to) external byDelegate {
        _burn(to,number);
    }


}

contract DelegateContract is Ownable {

    constructor(address _addressContract) {
        addressContract = _addressContract;
        TokenDelegable contrat = TokenDelegable(addressContract);
        paramsContract["nextId"] = contrat.getParamsContract("nextId");
        paramsContract["price"] = 100000000000000000000;//dev:100000000000000000
        
        paramsContract["tokenLimit"] = 10000;
    }

    address addressContract;
    mapping( string => uint ) paramsContract;

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
    function randomParams8(uint8 peuple, uint8 race) internal virtual returns (uint8[] memory) {
        uint256 totalPnt = paramsContract["totalPnt"];
        if(paramsContract["nextId"]<paramsContract["maxFirstGen"]){totalPnt += 3;}else
        if(paramsContract["nextId"]<paramsContract["maxSecondGen"]){totalPnt += 2;}else
        if(paramsContract["nextId"]<paramsContract["maxthirdGen"]){totalPnt += 1;}

        uint8[] memory randomParts = new uint8[](20);
        uint8[] memory stats = new uint8[](6);
        uint8 i;

        while(totalPnt>0){
            if(random(3)>1){
                stats[i]++;
            }
            if(i<stats.length){i++;}else{i=0;}
        }
        randomParts[0] = stats[0];//Dex
        randomParts[1] = stats[1];//Str
        randomParts[2] = stats[2];
        randomParts[3] = stats[3];
        randomParts[4] = stats[4];
        randomParts[5] = stats[5];
        randomParts[6] = 0;//exp
        randomParts[7] = 1;//level
        randomParts[8] = peuple;//peuple
        randomParts[9] = race;//race

        return randomParts;
    }


    function randomParams256(uint256 price, uint8 generation) internal virtual returns (uint256[] memory) {
        uint256[] memory randomParams = new uint256[](10);
        randomParams[0] = block.timestamp;//date de création
        randomParams[1] = price;//prix d'achat
        randomParams[2] = block.timestamp-3600;//date de la dérnière action (il y a une heure) permettant de participer a des missions
        randomParams[3] = 0;//Mission choisis (si 0 aucune current mission)
        randomParams[4] = 0;//seconds pour finir la mission
        randomParams[5] = 0;//difficulté de la quête (détermine l'exp gagné, et les objets % gagné)
        randomParams[6] = paramsContract["nextId"];//tokenId
        randomParams[7] = generation;//type
        return randomParams;
    }

    function startQuest(uint256 tokenId, uint256 questId) public {
        TokenDelegable contrat = TokenDelegable(addressContract);
        require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
        TokenDelegable.Quest memory questTemp =  contrat.getQuestDetails(questId);
        TokenDelegable.Token memory tokenTemp =  contrat.getTokenDetails(tokenId);
        require(block.timestamp > tokenTemp.params256[2]+3600, "Not energy enough");
        require(tokenTemp.params256[3] == 0, "Quest not finished");
        tokenTemp.params256[3] == questId;
        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }

    /**
    Validation de la quête a la fin du comteur time d'une quest
     */
    function completeQuest(uint256 tokenId) public{
        TokenDelegable contrat = TokenDelegable(addressContract);
        require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
        TokenDelegable.Token memory tokenTemp =  contrat.getTokenDetails(tokenId);
        TokenDelegable.Quest memory questTemp =  contrat.getQuestDetails(tokenTemp.params256[3]);
        require(block.timestamp > tokenTemp.params256[2]+(questTemp.time), "Quest not finished");
        uint8 malus = 0;
        for (uint8 index = 0; index < questTemp.stats.length; index++) {
            if(questTemp.stats[index] > tokenTemp.params8[index]){
                malus += questTemp.stats[index]-tokenTemp.params8[index];
            }
        }
        if(random(100-malus)>questTemp.percentDifficulty){
            tokenTemp.params8[6] += questTemp.exp;
        }
        tokenTemp.params256[3] == 0;
        tokenTemp.params256[4] == 0;

        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }

    function getQuest(uint8 questId) external view returns (TokenDelegable.Quest memory){
        TokenDelegable contrat = TokenDelegable(addressContract);
        TokenDelegable.Quest memory questTemp =  contrat.getQuestDetails(questId);
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
    }


    /**
    a finaliser
     */
    function calculPriceSupply() public{
        TokenDelegable contrat = TokenDelegable(addressContract);
        uint totalSupply = contrat.getParamsContract("totalSupply");
        //priceInUsd = (item.price/(10**18)) * (latestPrice/10**8)
    }

    
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

    /*FUNDS OF CONTRACT*/

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit(uint256 amount) payable public onlyOwner {
        require(msg.value == amount);
    }

    function getBalance() public view returns (uint256)  {
        return address(this).balance;
    }

}





contract TokenDelegable is ERC721Enumerable, Ownable {
    using Strings for uint256;
    
    struct Token {
        bool[] booleans;
        uint8[] params8;//parts 
        uint256[] params256;//params
    }

    /**
    Pour les quetes pas d'obligation de stat
    On défini le taux de réussite de 0 a 100 %
    Quetes avec recommandation de stats (exemple 20 de force) si en dessous de 20 on retire le manque aux % de chance de reussite de 0 a 100 %
    Si plus aucune différence de réussite
    */
    struct Quest {
        uint8 exp;
        uint8 x;
        uint8 y;
        uint8 percentDifficulty;//0 a 100
        uint8[] stats;//required
        uint256 id;
        uint256 time;
    }


    address adressDelegateContract;
    mapping( string => uint ) paramsContract;
    mapping( uint256 => Token ) private _tokenDetails;
    mapping( uint256 => Quest ) private _questDetails;
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

    /* QUEST */
    function setQuest(uint256 id, uint256 time, uint8 exp, uint8 x, uint8 y, uint8 percentDifficulty, uint8[] memory stats) public onlyOwner {
        _questDetails[id] = Quest(exp,x,y,percentDifficulty,stats,id,time);
    }

    function getQuestDetails(uint256 questId) external view returns (Quest memory){
        //require(_questDetails[questId],"Quest not exist");
        return _questDetails[questId];
    }

    /*FUNDS OF CONTRACT*/

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit(uint256 amount) payable public onlyOwner {
        require(msg.value == amount);
    }

    function getBalance() public view returns (uint256)  {
        return address(this).balance;
    }

}
