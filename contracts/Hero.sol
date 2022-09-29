// SPDX-License-Identifier: MIT
// Token Myos
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Hero is ERC721URIStorage, Ownable {
    using Strings for uint256;

    struct Token {
        bool[] booleans;
        uint8[] params8; //parts
        uint256[] params256; //params
    }

    address adressDelegateContract;
    mapping(string => uint256) paramsContract;
    mapping(uint256 => Token) private _tokenDetails;

    string public baseURI;
    string public baseExtension = ".json";
    bool public paused = false;

    constructor(
        string memory name,
        string memory symbol,
        string memory _initBaseURI
    ) ERC721(name, symbol) {
        paramsContract["nextId"] = 0;
        paramsContract["totalSupply"] = 0;
        setBaseURI(_initBaseURI);
    }

    ///@notice Retourne un nombre aléatoire jusqu'a un maxNumber défini
    function random(uint8 maxNumber) internal returns (uint8) {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    msg.sender,
                    paramsContract["nonce"]
                )
            )
        ) % maxNumber;
        paramsContract["nonce"]++;
        return uint8(randomnumber);
    }

    ///@notice Retourne les metadatas d'un token, essentiel pour opensea et autres plateform
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    ///@notice Mettre a jour l'uri des metadatas des tokens
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    ///@notice Retourne les metadatas d'un token, essentiel pour opensea et autres plateform
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    ///@notice Foncton très importante que l'ont rajoute sur presque toutes les autres fonctions pour vérifier que l'appel des fonctions ce fais bien depuis le contrat de délégation pour plus de sécuriter
    modifier byDelegate() {
        require(
            (msg.sender == adressDelegateContract ||
                adressDelegateContract == address(0)) && !paused,
            "Not good delegate contract"
        );
        _;
    }

    ///@notice Mêttre en pause le contrat en cas de problème
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    ///@notice Fonction de mint, on envoi un tableau de uint8 et un tableau de uint256 qui seront les params de notre token, On enregistre la struct dans un mapping avec la key id, Puis on mint avec la même key id
    function mint(
        address receiver,
        bool[] memory booleans,
        uint8[] memory params8,
        uint256[] memory params256,
        string memory _tokenURI
    ) external payable byDelegate {
        _tokenDetails[paramsContract["nextId"]] = Token(
            booleans,
            params8,
            params256
        );
        paramsContract["nextId"]++;
        paramsContract["totalSupply"]++;
        _safeMint(receiver, paramsContract["nextId"]);
        _setTokenURI(paramsContract["nextId"], _tokenURI);
    }

    ///@notice Burn un token avec son id et diminué le total supply
    function burn(uint256 tokenId) external byDelegate {
        paramsContract["totalSupply"]--;
        _burn(tokenId);
    }

    ///@notice Transféré un token d'une adresse à une autre en utilsant l'id token
    function transfer(
        address from,
        address to,
        uint256 tokenId
    ) external byDelegate {
        _safeTransfer(from, to, tokenId, "");
    }

    ///@notice Récupérer dans un tableau tout les id token d'un utilisateur
    function getAllTokensForUser(address user)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(user);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = paramsContract["nextId"];
            uint256 resultIndex = 0;
            uint256 i;
            for (i = 0; i < totalTokens; i++) {
                if (ownerOf(i) == user) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }

    ///@notice Mêttre a jour le Token (hero) en cas de level up par example en utilisant l'id en clé et en envoyant directement l'objet de la mise a jour du token
    function updateToken(
        Token memory tokenTemp,
        uint256 tokenId,
        address owner
    ) external byDelegate {
        require(ownerOf(tokenId) == owner, "Not Your token");
        _tokenDetails[tokenId] = tokenTemp;
    }

    ///@notice Récupérer les datas d'un token en utilisant son id
    function getTokenDetails(uint256 tokenId)
        external
        view
        returns (Token memory)
    {
        return _tokenDetails[tokenId];
    }

    ///@notice Mêttre a jour une des datas du cotnrat en utilisant la key
    function setParamsContract(string memory keyParams, uint256 valueParams)
        external
        onlyOwner
    {
        paramsContract[keyParams] = valueParams;
    }

    ///@notice Récuperer une des datas du contrat en utilisant la key
    function getParamsContract(string memory keyParams)
        external
        view
        returns (uint256)
    {
        return paramsContract[keyParams];
    }

    ///@notice modifier l'addresse du contrat de délégation pour permettre aux dit contrat d'intéragir avec celui ci
    function setAdressDelegateContract(address _adress) external onlyOwner {
        adressDelegateContract = _adress;
    }

    ///@notice FUNDS OF CONTRACT

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit() public payable onlyOwner {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    ///@notice Récupérer l'adresse du possesseur du token en utilisant la key id du token
    function getOwnerOf(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }

    ///@notice Récupérer le nombre de token possédé par un joueur
    function getBalanceOf(address user) external view returns (uint256) {
        return balanceOf(user);
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
