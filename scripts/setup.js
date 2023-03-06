const { assert, expect } = require("chai")
const { network, deployments, ethers, getNamedAccounts } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { moveBlocks } = require("../utils/move-blocks")

async function setup() {
    let Dex, dexToken, LPToken, tokenControl
    const txNumber = 1
    deployer = (await getNamedAccounts()).deployer
    //player = (await getNamedAccounts()).player  we can grab the player account from get named accounts
    const accounts = await ethers.getSigners() //its better for ethers if we use get signers, since the account object will be aligned with the ether call functions
    player = accounts[1]
    Dex = await ethers.getContract("DexV1")
    dexToken = await ethers.getContract("DEXToken")
    tokenControl = await ethers.getContract("DEXTokenControlMultiSig")
    LPToken = await ethers.getContract("LPToken")
    console.log(`player address: ${player.address}`)
    console.log(`dex addres: ${Dex.address}`)
    console.log(`token address: ${dexToken.address}`)
    console.log(`control address: ${tokenControl.address}`)
    console.log(`LPtoken address: ${LPToken.address}`)
    console.log("setting LPtoken")
    //    //const setLPtokenAddressTx = await Dex.setLPTokenAddress(LPToken.address)
    ////const setLPReceipt = await setLPtokenAddressTx.wait(1)

    //console.log("queueing mint")
    //const tokensMinted = ethers.utils.parseEther("1000")
    ////const queueMintTX = await tokenControl.erc20Mint(dexToken.address, tokensMinted)
    ////await queueMintTX.wait(1)
    ////console.log("adding owners")
    ////const addOwner1TX = await tokenControl.addOwner("0x684585a4e1f28d83f7404f0ec785758c100a3509")
    ////await addOwner1TX.wait(1)
    //const addOwner2TX = await tokenControl.addOwner("0xFF5bE4c96A0f54d86a6b1D709e4C05601C8ea0AB")
    //await addOwner2TX.wait(1)
    //console.log("owners added, confirming tx")
    ////const confirmTX1 = await tokenControl.confirmTransaction(txNumber)
    ////await confirmTX1.wait(1)
    //tokenControl1 = await tokenControl.connect(player)

    //const confirmTX2 = await tokenControl1.confirmTransaction(txNumber)
    //await confirmTX2.wait(1)
    //console.log("confirmations performed, executing tx")

    //const executeTX = await tokenControl.executeTransaction(txNumber)
    //await executeTX.wait(1)
    //console.log("transaction executed, approving DEX")

    //const approveTX = await dexToken.approve(Dex.address, tokensMinted)

    //await approveTX.wait(1)
    console.log("dex approved, ready to init dex")

    const initTX = await Dex.init({ value: ethers.utils.parseEther("0.5").toString() })

    await initTX.wait(1)
    console.log("Dex initialized")
}

setup().catch((error) => {
    console.log(error)
    process.exitCode = 1
})
