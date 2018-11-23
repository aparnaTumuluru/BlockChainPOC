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
contract TitleLicenceAgreementv12 is AppBuilderBase("TitleLicenceAgreementv12") {


	enum ContractStates { Created, RoyaltyConfigured,Terminated, RoyaltyModified, UsageRecorded, OwnerShipTransferred, GameDetailsModified }

	string public GameTitle;
	string public GameDescription;
	uint public TotalPrice;
	address public Developer;
	address public Designer;
	uint public DeveloperRoyalty;
	uint public DesignerRoyalty;
	address public Admin;
	address public Reviewer;
	address public Manager;
	address public User1;
	address public User2;
	ContractStates public State;
 	mapping(address=>UsageContractv12[]) userUsage;
	 uint public DeveloperBalance;
	 uint public DesignerBalance;
 
	function TitleLicenceAgreementv12(string Game_Title, string Game_Description, uint Total_Price, address User_1, address User_2,address Level1_Approver,address Level2_Approver) {
		Admin = msg.sender;
		GameTitle = Game_Title;
		GameDescription = Game_Description;
		TotalPrice = Total_Price;
		User1 = User_1;
		User2 = User_2;
		State = ContractStates.Created;
		Reviewer =Level1_Approver;
		Manager =Level2_Approver;
		DeveloperBalance =0;
		DesignerBalance =0;
		ContractCreated();
	}
	function SetRoyalty(address Developer_Id, uint Developer_Royalty, address Designer_Id, uint Designer_Royalty) {
		if (Admin != msg.sender || State != ContractStates.Created) {
			revert();
		}
		Developer = Developer_Id;
		Designer = Designer_Id;
		DeveloperRoyalty=Developer_Royalty ;
		DesignerRoyalty=Designer_Royalty;
		State = ContractStates.RoyaltyConfigured;

		ContractUpdated("SetRoyalty");
	}
	function ModifyRoyalty(uint Developer_Royalty, uint Designer_Royalty) {
		if (Admin != msg.sender || State != ContractStates.Created) {
			revert();
		}
		DeveloperRoyalty=Developer_Royalty ;
		DesignerRoyalty=Designer_Royalty;
		State = ContractStates.RoyaltyModified;

		ContractUpdated("ModifyRoyalty");
	}
	function Terminate() {
		if (Admin != msg.sender || State != ContractStates.Created) {
			revert();
		}
		 State = ContractStates.Terminated;

		ContractUpdated("Terminate");
	}
	function Modify(string Game_Title, string Game_Description, uint Price) {
	 	if (Developer != msg.sender){
			 revert();
		 }
		GameTitle = Game_Title;
		GameDescription = Game_Description;
		TotalPrice = Price;
 		State = ContractStates.GameDetailsModified;

		ContractUpdated("Modify");
	}
	function Transfer(address TransferTo) {
	 
		if (msg.sender == Developer) {
				Developer = TransferTo;
		}else if (msg.sender == Designer) {
				Designer = TransferTo;
		}	

		State = ContractStates.OwnerShipTransferred;
		ContractUpdated("Transfer");
	}
	function RecordUsage(uint NumberOfDownloads) {
		 
		UsageContractv12 usageContract  = new UsageContractv12(DeveloperRoyalty,DesignerRoyalty,Reviewer,Manager,msg.sender,TotalPrice,NumberOfDownloads,this);
		userUsage[msg.sender].push(usageContract);
		State = ContractStates.UsageRecorded;

		ContractUpdated("RecordUsage");
	}
	function UpdateBalance(uint DevRoyalty,uint DesRoyalty) { 
		DeveloperBalance += DevRoyalty;
		DesignerBalance += DesRoyalty;
		ContractUpdated("updateBalance");
	}
	
}
contract UsageContractv12 is AppBuilderBase("UsageContractv12") {


	enum ContractStates { PendingReview, Reviewed, PendingManagerApproval, ReviewerApproved, ReviewerRejected, ManagerApproved, ManagerRejected, PaidRoyalty }

	uint public DeveloperRoyaltyPercent;
	uint public DesignerRoyaltyPercent;
	address public Reviewer;
	address public Manager;
	address public User;
	ContractStates public State;
	uint public TotalRoyaltyPayout;
	uint public DeveloperPayout;
	uint public DesignerPayout;
	uint public Price;
	uint public NumberOfDownloads;
	TitleLicenceAgreementv12 TLARef;

	function UsageContractv12(uint developerRoyaltyPercent, uint designerRoyaltyPercent, address Level1_Approver, address Level2_Approver, address user,uint price, uint numberOfViews,address TLAContract) {
		User = msg.sender;
		DeveloperRoyaltyPercent = developerRoyaltyPercent;
		DesignerRoyaltyPercent = designerRoyaltyPercent;
		Reviewer = Level1_Approver;
		Manager = Level2_Approver;
		User = user;
		State = ContractStates.PendingReview;
		Price = price;
		NumberOfDownloads =numberOfViews;
		TLARef = TitleLicenceAgreementv12(TLAContract);
		ContractCreated();
	}
	function Inspect() {
		if (Reviewer != msg.sender || State != ContractStates.PendingReview) {
			revert();
		}
		State = ContractStates.Reviewed;
		TotalRoyaltyPayout = Price*NumberOfDownloads*(DeveloperRoyaltyPercent+DesignerRoyaltyPercent)/100;
		ContractUpdated("Inspect");
	}
	function Approve() {
		if (Reviewer != msg.sender || State != ContractStates.Reviewed) {
			revert();
		}
		if(TotalRoyaltyPayout > 500) {

			State = ContractStates.PendingManagerApproval;
		}
		else{
			State = ContractStates.ReviewerApproved;
		}

		ContractUpdated("Approve");
	}
	function ManagerApprove() {
		if (Manager != msg.sender || State != ContractStates.PendingManagerApproval) {
			revert();
		}
		 State = ContractStates.ManagerApproved;

		ContractUpdated("ManagerApprove");
	}
	function Reject() {
		if (Reviewer == msg.sender || State == ContractStates.Reviewed) {
			State = ContractStates.ReviewerRejected;
		}else if (Manager == msg.sender || State == ContractStates.PendingManagerApproval) {
			State = ContractStates.ManagerRejected;
		}
		ContractUpdated("Reject");
	}
	function Pay() {
		if (Reviewer != msg.sender ) {
			revert();
		}
		DeveloperPayout =Price*NumberOfDownloads*DeveloperRoyaltyPercent/100;
		DesignerPayout = Price*NumberOfDownloads*DesignerRoyaltyPercent/100;
		TLARef.UpdateBalance(DeveloperPayout,DesignerPayout);

		State = ContractStates.PaidRoyalty;

		ContractUpdated("Pay");
	}
}

