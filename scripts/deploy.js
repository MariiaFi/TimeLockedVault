async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contract with account:", deployer.address);

  const Vault = await ethers.getContractFactory("TimeLockedVault");
  const vault = await Vault.deploy();

  await vault.deployed();

  console.log("Contract deployed to:", vault.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
