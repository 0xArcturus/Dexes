const { getNamedAccounts, deployments, network, ethers } = require("hardhat")
const {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    await verify("0x4786ee6a359b9916ab55e76747cf6b9d711f5de0", [])
}

module.exports.tags = ["all", "verify"]
