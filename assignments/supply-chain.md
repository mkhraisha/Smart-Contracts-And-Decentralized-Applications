# supply-chain-dapp

## In this assignment, you will be building a real-world Supply chain decentralized application by following the steps:

### Step 1:

The first thing we need is a Management Smart Contract, where we can add items.

`ItemManager.sol`

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract ItemManager{
    enum SupplyChainSteps{Created, Paid, Delivered}

    struct S_Item {
        ItemManager.SupplyChainSteps _step;
        string _identifier;
        uint _priceInWei;
    }

    mapping(uint => S_Item) public items;
    uint index;

    event SupplyChainStep(uint _itemIndex, uint _step);

    function createItem(string memory _identifier, uint _priceInWei) public {
        items[index]._priceInWei = _priceInWei;
        items[index]._step = SupplyChainSteps.Created;
        items[index]._identifier = _identifier;
        emit SupplyChainStep(index, uint(items[index]._step));
        index++;
    }

    function triggerPayment(uint _index) public payable {
        require(items[index]._priceInWei <= msg.value, "Not fully paid");
        require(items[index]._step == SupplyChainSteps.Created, "Item is further in the supply chain");
        items[_index]._step = SupplyChainSteps.Paid;
        emit SupplyChainStep(_index, uint(items[_index]._step));
    }

    function triggerDelivery(uint _index) public {
    require(items[_index]._step == SupplyChainSteps.Paid, "Item is further in the supply chain");
    items[_index]._step = SupplyChainSteps.Delivered;
    emit SupplyChainStep(_index, uint(items[_index]._step));
    }
}
```

Its purpose is to add items and pay them, move them forward in the supply chain and trigger a delivery. Instead, we can just give the user a simple address to send money to.

### Step 2:

Add another contract called `Item.sol`

`Item.sol`

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

import "./ItemManager.sol";
contract Item {
    uint public priceInWei;
    uint public paidWei;
    uint public index;
    ItemManager parentContract;
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(msg.value == priceInWei, "We don't support partial payments");
        require(paidWei == 0, "Item is already paid!");
        paidWei += msg.value;
        (bool success, ) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "Delivery did not work");
    }

    fallback () external {
    }
}
```

And change the ItemManager Smart Contract to use the Item Smart Contract instead of the `struct` only:

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

import "./Item.sol";

contract ItemManager {
    struct S_Item {
    Item _item;
    ItemManager.SupplyChainSteps _step;
    string _identifier;
    }

    mapping(uint => S_Item) public items;
    uint index;
    enum SupplyChainSteps {Created, Paid, Delivered}

    event SupplyChainStep(uint _itemIndex, uint _step, address _address);

    function createItem(string memory _identifier, uint _priceInWei) public {
        Item item = new Item(this, _priceInWei, index);
        items[index]._item = item;
        items[index]._step = SupplyChainSteps.Created;
        items[index]._identifier = _identifier;
        emit SupplyChainStep(index, uint(items[index]._step), address(item));
        index++;
    }

    function triggerPayment(uint _index) public payable {
        Item item = items[_index]._item;
        require(address(item) == msg.sender, "Only items are allowed to update themselves");
        require(item.priceInWei() == msg.value, "Not fully paid yet");
        require(items[index]._step == SupplyChainSteps.Created, "Item is further in the supply chain");
        items[_index]._step = SupplyChainSteps.Paid;
        emit SupplyChainStep(_index, uint(items[_index]._step), address(item));
    }

    function triggerDelivery(uint _index) public {
        require(items[_index]._step == SupplyChainSteps.Paid, "Item is further in the supply chain");
        items[_index]._step = SupplyChainSteps.Delivered;
        emit SupplyChainStep(_index, uint(items[_index]._step), address(items[_index]._item));
    }
}
```

Now with this, we just have to give a customer the address of the Item Smart Contract created during createItem and he will be able to pay directly by sending X wei to the Smart Contract. But the smart contract isn’t very secure yet. We need some sort of owner functionality.

### Step 3:

Add `onlyOwner` Modifiers and `Ownable` Functionality.
You could add the OpenZeppelin Smart Contracts with the Ownable Functionality.

`Ownable.sol`

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract Ownable {
    address public _owner;

    constructor () internal {
        _owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Returns true if the caller is the current owner.
    */
    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }
}
```

Modify `ItemManager.sol` by adding an `Ownable` contract.

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {
    //...
    function createItem(string memory _identifier, uint _priceInWei) public onlyOwner {
        //...
    }
    function triggerPayment(uint _index) public payable {
        //...
    }

    function triggerDelivery(uint _index) public onlyOwner {
        //...
    }

    // ....
}
```

### Step 4:

Installing truffle and unboxing the project
If you do not have installed truffle globally then Run

```sh
$ npm install -g truffle
```

Create a directory called module7_assignment go inside that directory using

```sh
$ cd ./module7_assignment
```

Unbox the react project running following command

```sh
$ truffle unbox react
```

This command should download a repository and install all dependencies in the current folder. Open the project in your favourite IDE. We will be showing the steps assuming [Visual Studio Code](https://code.visualstudio.com/).

### Step 5:

Now you’ll add the contracts created in previous steps and remove `SimpleStorage.sol`.

<img src="./images/remove-simple-storage.png" width=400 />

And add the files created previously:

<img src="./images/add-files.png" width=200 />

Now modify the migration file:

`Migrations.sol`

```js
const ItemManager = artifacts.require("./ItemManager.sol");
module.exports = function (deployer) {
  deployer.deploy(ItemManager);
};
```

Modify the `truffle-config.js` file to lock in a specific compiler version:

`truffle-config.js`

```js
const path = require("path");
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      port: 8545,
    },
  },
  compilers: {
    solc: {
      version: "0.6.10",
    },
  },
};
```

Run the truffle develop console to check if everything is alright and can be migrated:
On the terminal run:

```sh
$ truffle develop
$ truffle migrate
```
<img src="./images/truffle-migrate.png" width=400 />

### Step 6:

- Modify the HTML to add the Items to ItemManager
- Open `client/App.js` and modify the beginning of the file:

```js
import React, { Component } from "react";
import ItemManager from "./contracts/ItemManager.json";
import Item from "./contracts/Item.json";
import getWeb3 from "./getWeb3";
import "./App.css";
class App extends Component {
    state = {cost: 0, itemName: "exampleItem1", loaded:false};

    componentDidMount = async () => {
        try {
            // Get network provider and web3 instance.
            this.web3 = await getWeb3();
            // Use web3 to get the user's accounts.
            this.accounts = await this.web3.eth.getAccounts();
            // Get the contract instance.
            const networkId = await this.web3.eth.net.getId();
            this.itemManager = new this.web3.eth.Contract(
                ItemManager.abi,
                ItemManager.networks[networkId] && ItemManager.networks[networkId].address,
            );
            this.item = new this.web3.eth.Contract(
                Item.abi,
                Item.networks[networkId] && Item.networks[networkId].address,
            );
            this.setState({loaded:true});
        } catch (error) {
            // Catch any errors for any of the above operations.
            alert(`Failed to load web3, accounts, or contract. Check console for details.`,);
            console.error(error);
        }
    };

    //.. more code here ...
```

Then add in a form to the HTML part on the lower end of the `App.js` file, in the `render` function:

```js
render() {
    if (!this.state.loaded) {
        return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
        <div className="App">
        <h1>Simply Payment/Supply Chain Example!</h1>
        <h2>Items</h2>
        <h2>Add Element</h2>
        Cost: <input type="text" name="cost" value={this.state.cost} onChange={this.handleInputChange} />
        Item Name: <input type="text" name="itemName" value={this.state.itemName} onChange={this.handleInputChange} />
        <button type="button" onClick={this.handleSubmit}>Create new Item</button>
        </div>
    );
}
```

And add two functions, one for `handleInputChange`, so that all input variables are set correctly. And one for sending the actual transaction off to the network:

```js
handleSubmit = async () => {
    const { cost, itemName } = this.state;
    console.log(itemName, cost, this.itemManager);
    let result = await this.itemManager.methods.createItem(itemName, cost).send({ 
        from:this.accounts[0] 
        });
    console.log(result);
    alert("Send "+cost+" Wei to "+result.events.SupplyChainStep.returnValues._address);
    };

    handleInputChange = (event) => {
        const target = event.target;
        const value = target.type === 'checkbox' ? target.checked : target.value;
        const name = target.name;
        this.setState({
            [name]: value
        });
    }
```

Open another terminal (leave the one running) and go to the client folder and run
```sh
$ npm start
```
This will start the development server on port 3000 and should open a new tab in your browser:

<img src="./images/output.png" width=400 />

> Do not worry about the error message that the network wasn’t found or the contract wasn’t found under the address provided. Follow along in the next step where you change the network in MetaMask! As long as there is no error in your terminal and it says “Compiled successfully” you’re good to go.

### Step 7:
Connect Metamask and add Private key to MetaMask

First, connect with MetaMask to the right network.

<img src="./images/mm-network.png" width=250 />

- When we migrate the smart contracts with Truffle Developer console, then the first account in the truffle developer console is the “owner”. 
- So, either we disable MetaMask in the Browser to interact with the app or we add in the private key from truffle developer console to MetaMask.
- In the Terminal/Powershell where Truffle Developer Console is running scroll to the private keys on top:

<img src="./images/pk-copy.png" width=400 />

Copy the Private Key and add it into MetaMask:

<img src="./images/import-pk.png" width=300 />

- Then your new Account should appear here with ~100 Ether in it.
- Now let’s add a new Item to our Smart Contract. You should be presented with the popup to send the message to an end-user.

<img src="./images/send-pop-up.png" width=300 />

### Step 8:
- Listen to payments

- Now that you know how much to pay to which address you need some sort of feedback. Obviously, you don’t want to wait until the customer tells you that he paid, you want to know right on the spot if a payment happened.
- There are multiple ways to solve this particular issue. For example, you could poll the Item smart contract. 
- You could watch the address on a low-level for incoming payments. We will wait for the event “SupplyChainStep” to trigger with _step == 1 (Paid).
Let’s add another function to the `App.js` file:

```js
listenToPaymentEvent = () => {
    let self = this;
    this.itemManager.events.SupplyChainStep().on("data", async function(evt) {
    if(evt.returnValues._step == 1) {
        let item = await self.itemManager.methods.items(evt.returnValues._itemIndex).call();
        console.log(item);
        alert("Item " + item._identifier + " was paid, deliver it now!");
    };
    console.log(evt);
    });
}
```

And call this function when we initialize the app in `componentDidMount`:

```js
//...
this.item = new this.web3.eth.Contract(
    ItemContract.abi,
    ItemContract.networks[this.networkId] && ItemContract.networks[this.networkId].address,
);
// Set web3, accounts, and contract to the state, and then proceed with an
// example of interacting with the contract's methods.
this.listenToPaymentEvent();
this.setState({ loaded:true });
} catch (error) {
// Catch any errors for any of the above operations.
alert(
`Failed to load web3, accounts, or contract. Check console for details.`,
);
console.error(error);
}
//...
```

Whenever someone pays the item a new popup will appear telling you to deliver. You could also add this to a separate page, but for simplicity, we will just add it as an alert popup to showcase the trigger-functionality:

<img src="./images/pay-mm-popup.png" width=300 />

Take the address, give it to someone telling them to send `100 wei` (`0.0000000000000001 ether`) and a bit more gas to the specified address. You can do this either via MetaMask or via the `truffle console`:

```sh
web3.eth.sendTransaction({to: "ITEM_ADDRESS", value: 100, from: accounts[1],
gas: 2000000});
```

Then a popup should appear on the website

<img src="./images/deliver-popup.png" width=300 />

### Step 9:
Unit test functionality
Unit testing is important, that’s out of the question. You will implement a simple unit test. First of all, delete the tests in the `/test` folder. They are for the simplestorage smart contract which doesn’t exist anymore. Then add new tests:

`itemmanager.test.js`

```js
const ItemManager = artifacts.require("./ItemManager.sol");
contract("ItemManager", accounts => {
    it("... should let you create new Items.", async () => {
        const itemManagerInstance = await ItemManager.deployed();
        const itemName = "test1";
        const itemPrice = 500;
        const result = await itemManagerInstance.createItem(itemName, itemPrice, { from: accounts[0] });
        assert.equal(result.logs[0].args._itemIndex, 0, "There should be one item index in there")
        const item = await itemManagerInstance.items(0);
        assert.equal(item._identifier, itemName, "The item has a different identifier");
    });
});
```

Mind the difference: In web3js you work with `instance.methods.createItem` while in truffle-contract you work with `instance.createItem`. Also, the events are different. In web3js you work with `result.events.returnValues` and in truffle-contract you work with `result.logs.args`. Keep the truffle development console open and type in a new terminal window:

```sh
$ truffle test
```

It should bring up a test like this:

<img src="./images/compile.png" width=300 />

Your assignment is completed. Zip the truffle project and submit to the dropbox. Do not include the `node_modules` folder in the zip else you’ll receive 0 (but you can resubmit).

### Bonus Step
- Remove the files under the `test` directory.
- Add a new file called `ItemManager.test.js` and write the test scripts for testing `ItemManager.sol` contract.
- Add code coverage for solidity. (Follow this [readme](https://github.com/sc-forks/solidity-coverage#solidity-coverage) to add solidity coverage plugin to the project.)