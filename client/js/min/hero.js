
async function selectClass(allClasses){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();

    if(connected == true){
        let abiclass = await getAbiClass();
        let contractClass = new web3.eth.Contract(abiclass, CONTRACT_ADDRESS_CLASS);
        retour = "<select class='hero-class-select'>"
        allClasses.forEach(classe => {
        contractClass.methods.getClassDetails(classe).call({from: ethereum.selectedAddress}).then((oneClass)=>{
            //console.log(oneClass)
            retour += "<option value='"+oneClass.id+"'>"+oneClass.name+"</option>"
        })
            
        });
        setTimeout(() => {
        retour += "</select>"
        $("#select-class").html(retour);
        }, 500);
    }
}


async function mint(){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    //console.log(connected)
    if(connected == true){
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    await contract.methods.mintDelegate(0,0,$(".hero-class-select").val()).send({
        from: ethereum.selectedAddress,
        value:web3.utils.toWei(pricemint, "wei"),
        //gasPrice: '1000000000',//gwei 1
        //gasPrice: '30',
        //gas: 1000000,
    }).catch((error)=>{
        console.log('error transfer',error)
        console.log(error.message)
    }).then(()=>{
        startMain()
    });
    }
}

async function levelUp(idHero){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    //console.log(connected)
    if(connected == true){
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    await contract.methods.levelUp($("#select-stat-level-up").val(),idHero).send({
        from: ethereum.selectedAddress,
        //value:web3.utils.toWei(pricemint, "wei"),
        //gasPrice: '1000000000',//gwei 1
        //gasPrice: '30',
        //gas: 1000000,
    }).catch((error)=>{
        console.log('error transfer',error)
        console.log(error.message)
    }).then(()=>{
        startMain()
    });
    }
}

async function getAllHero(){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
    let renderHeroes="";
    let abi = await getAbi();
    console.log(web3.eth)
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    let heroes = await contract.methods.getAllTokensForUser(ethereum.selectedAddress).call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)});
    await heroes.forEach((MYO) => {
        contract.methods.getTokenDetails(MYO).call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)}).then((data)=>{
        myHeroes[MYO] = data;
        renderHeroes += renderHero(data)
        //timeOut++
        /*setTimeout(() => {
            sendToServerMeta(data,MYO)
        }, 2000*timeOut);*/
        //break;//A DEGAGER
        });
    })
    setTimeout(() => {
        console.log(renderHeroes)
        $("#heroes").html(renderHeroes);
        getAllQuestAdmin();
    }, 2000);
    }
}

function renderHero(data){
    return "<div class='card col-3'><strong class='card-header'>#"+data.params256[6]+"</strong>"
    +"<div class='card-body'>"
    +"<div>STR : "+data.params8[0]+"</div>"
    +"<div>DEX : "+data.params8[1]+"</div>"
    +"<div>AGI : "+data.params8[2]+"</div>"
    +"<div>END : "+data.params8[3]+"</div>"
    +"<div>INT : "+data.params8[4]+"</div>"
    +"<div>? : "+data.params8[5]+"</div>"
    +"<div>EXP : "+data.params8[6]+" / "+(100+(100**data.params8[7]))+"</div>"
    +"<div>LEVEL : "+data.params8[7]+"</div>"
    +"<div>In Quest : "+data.params256[3]+"</div>"
    //+"<div>Time for finish : "+data.params256[4]+"</div>"
    +((data.params8[6]>=(100+(100**data.params8[7])))?"<span class='badge badge-dark m-1 p-1' onclick='levelUp(`"+(data.params256[6])+"`)' class='btn btn-dark'>Level up</span>":"")
    +((data.params8[6]>=(100+(100**data.params8[7])))?"<select id='select-stat-level-up'><option value='0'>str</option><option value='1'>str</option><option value='2'>str</option><option value='3'>str</option><option value='4'>str</option><option value='5'>str</option></select>":"")
    +"</div>"
    +"</div>"
    ;
}