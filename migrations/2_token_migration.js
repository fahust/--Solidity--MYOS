const { CONTRACT_VALUE_ENUM } = require("../enums/enum");

const Hero = artifacts.require("Hero");
const Class = artifacts.require("Class");
const Quest = artifacts.require("Quest");
const Items = artifacts.require("Items");
const Equipments = artifacts.require("Equipments");
const MYOS = artifacts.require("MYOS");
const ProxyHero = artifacts.require("ProxyHero");
const ProxyItems = artifacts.require("ProxyItems");
const ProxyEquipments = artifacts.require("ProxyEquipments");
const ProxyMYOS = artifacts.require("ProxyMYOS");

module.exports = async function (d, eployer) {
  await deployer.deploy(Hero, CONTRACT_VALUE_ENUM.NAME, CONTRACT_VALUE_ENUM.SYMBOL);
  const HeroContract = await Hero.deployed();

  await deployer.deploy(Class);
  const ClassContract = await Class.deployed();

  await deployer.deploy(Quest);
  const QuestContract = await Quest.deployed();

  await deployer.deploy(Items, CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH);
  const ItemsContract = await Items.deployed();

  await deployer.deploy(Equipments, CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH);
  const EquipmentsContract = await Equipments.deployed();

  await deployer.deploy(
    MYOS,
    CONTRACT_VALUE_ENUM.MAX_SUPPLY,
    CONTRACT_VALUE_ENUM.NAME,
    CONTRACT_VALUE_ENUM.SYMBOL,
  );
  const MYOSContract = await MYOS.deployed();

  await deployer.deploy(
    ProxyHero,
    HeroContract.address,
    QuestContract.address,
    ClassContract.address,
    ItemsContract.address,
  );
  const ProxyHeroContract = await ProxyHero.deployed();

  await deployer.deploy(ProxyItems, ItemsContract.address);
  const ProxyItemsContract = await ProxyItems.deployed();

  await deployer.deploy(
    ProxyEquipments,
    this.EquipmentsContract.address,
    this.ItemsContract.address,
  );
  const ProxyEquipmentsContract = await ProxyEquipments.deployed();

  await deployer.deploy(ProxyMYOS);
  const ProxyMYOSContract = await ProxyMYOS.deployed();

  console.log(HeroContract.address);
  console.log(ClassContract.address);
  console.log(QuestContract.address);
  console.log(ItemsContract.address);
  console.log(EquipmentsContract.address);
  console.log(MYOSContract.address);
  console.log(ProxyHeroContract.address);
  console.log(ProxyItemsContract.address);
  console.log(ProxyEquipmentsContract.address);
  console.log(ProxyMYOSContract.address);
};
