const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("TokenModule", (m) => {
  const token = m.contract("NFTMarketplace");

  return { token };
});

module.exports = TokenModule;