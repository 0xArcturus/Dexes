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
    const tokenControl = await deploy("YeahTokenControlMultiSig", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    yeahTokenArgs = [tokenControl.address]
    console.log(`deploying yeahToken with args ${yeahTokenArgs}`)
    const yeahToken = await deploy("YEAHToken", {
        from: deployer,
        args: yeahTokenArgs,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    dexArgs = [yeahToken.address]
    console.log(`deploying dex with args ${dexArgs}`)
    const Dex = await deploy("DexV1", {
        from: deployer,
        args: dexArgs,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    const networkName = network.name == "hardhat" ? "localhost" : network.name
    log(`deployed contract on ${networkName}`)
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(Dex.address, dexArgs)
        await verify(yeahToken.address, yeahTokenArgs)
        await verify(tokenControl.address, [])
    }
}

module.exports.tags = ["all", "contracts"]
