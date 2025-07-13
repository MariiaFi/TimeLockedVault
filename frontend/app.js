window.addEventListener("DOMContentLoaded", () => {
  let provider;
  let signer;
  let contract;

  const contractAddress = "0x5fbdb2315678afecb367f032d93f642f64180aa3";

  const connectButton = document.getElementById("connectWallet");
  const depositButton = document.getElementById("depositButton");
  const withdrawButton = document.getElementById("withdrawButton");
  const loadButton = document.getElementById("loadDepositsButton");
  const accountDiv = document.getElementById("account");

  const amountInput = document.getElementById("amountInput");
  const lockInput = document.getElementById("lockInput");
  const withdrawInput = document.getElementById("withdrawInput");
  const depositsList = document.getElementById("depositsList");

  connectButton.addEventListener("click", async () => {
    console.log("Connect button clicked");
    if (window.ethereum) {
      provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      signer = provider.getSigner();
      const address = await signer.getAddress();
      accountDiv.innerText = `Connected: ${address}`;
      contract = new ethers.Contract(contractAddress, abi, signer);
    } else {
      alert("Please install MetaMask!");
    }
  });

  depositButton.addEventListener("click", async () => {
    console.log("Deposit button clicked");
    if (!contract) return alert("Connect wallet first");

    const amount = amountInput.value;
    const lock = lockInput.value;

    if (!amount || !lock) return alert("Enter amount and lock duration");

    const tx = await contract.deposit(lock, {
      value: ethers.utils.parseEther(amount)
    });

    await tx.wait();
    alert("Deposit successful!");
  });

  loadButton.addEventListener("click", async () => {
    console.log("Load Deposits button clicked");
    if (!contract) return alert("Connect wallet first");

    const address = await signer.getAddress();
    const deposits = await contract.getDeposits(address);

    depositsList.innerHTML = "";

    deposits.forEach((d, i) => {
      const unlockDate = new Date(d.unlockTimestamp * 1000).toLocaleString();
      const li = document.createElement("li");
      li.textContent = `#${i}: ${ethers.utils.formatEther(d.amount)} ETH - Unlocks at ${unlockDate}`;
      depositsList.appendChild(li);
    });
  });

  withdrawButton.addEventListener("click", async () => {
    console.log("Withdraw button clicked");
    if (!contract) return alert("Connect wallet first");

    const index = withdrawInput.value;
    if (index === "") return alert("Enter deposit index");

    const tx = await contract.withdraw(index);
    await tx.wait();
    alert("Withdraw successful!");
  });
});
