const HDWalletProvider  = require('truffle-hdwallet-provider');
const Web3 = require('web3');

const{interface,bytecode}=require('./compile');

const provider = new HDWalletProvider('food merit monkey act input vast athlete kick memory frame winter crane'
,'https://rinkeby.infura.io/xuFhORCwjEtsVnod9M63');

const web3 = new Web3(provider);


const deploy = async()=>{
    
    const accounts = await web3.eth.getAccounts();//get the accounts and use the first one to deploy.
    
    result = await new web3.eth.Contract(JSON.parse(interface))

       .deploy({data:bytecode})
       .send({from:accounts[0],gas:'1000000'});
      console.log(interface);
       console.log('deploy address',result.options.address);

}
deploy();