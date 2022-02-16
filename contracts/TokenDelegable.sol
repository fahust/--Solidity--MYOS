pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

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
    function setParamsDelegate(string memory keyParams, uint256 valueParams ) external {
        TokenDelegable contrat = TokenDelegable(addressContract);
        contrat.setParamsContract(keyParams, valueParams);
    }

    /**
    appel vers le contrat officiel du jeton
    Offrir un ou plusieurs token a un utilisateur
     */
    function giveToken(bool[] memory booleans, uint8[] memory params8, uint256[] memory params256, address to) external onlyOwner{
        require(paramsContract["tokenLimit"] > 0,"No remaining");
        //uint8[] memory randomParts = randomParams8(bonus);
        //uint256[] memory randomParams = randomParams256(msg.value,typeMint);
        paramsContract["nextId"]++;

        TokenDelegable contrat = TokenDelegable(addressContract);
        contrat.mint(to, booleans, params8, params256);
    }

    /**
    appel vers le contrat officiel du jeton
    Modifier les paramètre d'un token et l'envoyé au contrat de token pour le mêttre a jour
     */
    function mintDelegate(bool[] memory booleans, uint8[] memory params8, uint256[] memory params256) external payable{
        require(msg.value >= paramsContract["price"],"More ETH required");
        require(paramsContract["tokenLimit"] > 0,"No remaining");
        //uint8[] memory randomParts = randomParams8(bonus);
        //uint256[] memory randomParams = randomParams256(msg.value,typeMint);
        paramsContract["nextId"]++;

        TokenDelegable contrat = TokenDelegable(addressContract);
        contrat.mint(msg.sender,booleans, params8, params256);
    }

    
    /**
    appel vers le contrat officiel du jeton
    Modifier les paramètre d'un token et l'envoyé au contrat de token pour le mêttre a jour
     */
    function paramsToken(uint256 tokenId,bool[] memory booleans, uint8[] memory params8, uint256[] memory params256) external {
        
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
    }

    
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

    function deposit(uint256 amount) payable public onlyOwner {
        require(msg.value == amount);
    }

    function getBalance() public view returns (uint256)  {
        return address(this).balance;
    }

}
