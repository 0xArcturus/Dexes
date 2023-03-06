const { getNamedAccounts, deployments, network, ethers } = require("hardhat")
const {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
    console.log("deploying tokenControl")
    const tokenControl = await deploy("DEXTokenControlMultiSig", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    DEXTokenArgs = [tokenControl.address]
    console.log(`deploying DEXToken with args ${DEXTokenArgs}`)
    const DEXToken = await deploy("DEXToken", {
        from: deployer,
        args: DEXTokenArgs,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    dexArgs = [DEXToken.address]
    console.log(`deploying dex with args ${dexArgs}`)
    const Dex = await deploy("DexV1", {
        from: deployer,
        args: dexArgs,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    console.log(`deploying dex with args ${dexArgs}`)
    LPtokenargs = [Dex.address]
    const LPToken = await deploy("LPToken", {
        from: deployer,
        args: LPtokenargs,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    const networkName = network.name == "hardhat" ? "localhost" : network.name
    log(`deployed contract on ${networkName}`)
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(Dex.address, dexArgs)
        await verify(DEXToken.address, DEXTokenArgs)
        await verify(tokenControl.address, [])
        await verify(LPToken.address, LPtokenargs)
    }
    const successSetLPTokenAddress = await Dex.setLPTokenAddress(LPToken.address)
    console.log(`LP address set: ${successSetLPTokenAddress}`)
}

module.exports.tags = ["all", "contracts"]
