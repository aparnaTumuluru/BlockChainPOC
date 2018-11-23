pragma solidity ^0.4.10;

contract AppBuilderBase {
	event AppBuilderContractCreated(string contractType, address originatingAddress);
	event AppBuilderContractUpdated(string contractType, string action, address originatingAddress);

	string internal ContractType;

	function AppBuilderBase(string contractType) internal {
		ContractType = contractType;
	}

	function ContractCreated() internal {
		AppBuilderContractCreated(ContractType, msg.sender);
	}

	function ContractUpdated(string action) internal {
	
			AppBuilderContractUpdated(ContractType, action, msg.sender);
	}
}



contract AssetContract is AppBuilderBase("AssetContract") {


	enum ContractStates { Created, Active, Updated, Transferred, Deleted }

	ContractStates public State;
	address public Owner;
	address public Reviewer;
	string public AssetDescription;
	uint public AssetPrice;
	string public AssetName;
	string public AssetType;
	address public Admin;
	//mapping(address=>UsageContract)  UserUsage;


	function AssetContract(string Description,address reviewer, uint256 Price,address owner,string Name,string TypeOfAsset) {
		Admin = msg.sender;
		Owner = owner;
		State = ContractStates.Active;
		AssetDescription = Description;
		AssetPrice = Price;
		AssetName = Name;
		Reviewer = reviewer;
		AssetType = TypeOfAsset;
		ContractCreated();
	}

	function UpdateAsset(string Description, uint256 Price,string Name,string TypeOfAsset) {
		if (Owner != msg.sender || State == ContractStates.Deleted) {
			revert();
		}
		//Please Fill in the remaining Business Logic
	   AssetDescription = Description;
		AssetPrice = Price;
		State = ContractStates.Updated;
		AssetName = Name;
		AssetType = TypeOfAsset;
		ContractUpdated("UpdateAsset");
	}
	function Transfer(address TransferTo){

		if (Owner != msg.sender || State == ContractStates.Deleted) {
			revert();
		}
		Owner = TransferTo;
		State = ContractStates.Transferred;
		ContractUpdated("TransferAsset");
	}
	function Terminate(){

		if (Owner != msg.sender) {
			revert();
		}
		State = ContractStates.Deleted;
		ContractUpdated("TerminateAsset");
	}
	function UseAsset(uint duration){
		if (Owner == msg.sender|| Reviewer==msg.sender ) {
			revert();
		}
		  // UserUsage[msg.sender]!=address(0)
	 	//UserDurations[msg.sender] = duration;
	//	UsageContract Usage = new UsageContract(Owner,Price,Reviewer,NumberOfViews);
		ContractUpdated("UseAsset");
	}


}
