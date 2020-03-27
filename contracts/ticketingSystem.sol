pragma solidity >0.5.0;
pragma experimental ABIEncoderV2;

contract ticketingSystem {
    struct Artist{
        bytes32 name;
        uint artistCategory;
        address owner;
        uint ticketSold;
    }

    struct Venue{
        bytes32 name;
        uint capacity;
        uint standardComission;
        address owner;
    }

    struct Concert{
        uint concertDate;
        uint artistId;
        uint ticketPrice;
        uint totalsldTicket;
        uint totalMoneyCollected;
        uint venueId;
        bool validatedByArtist;
        bool validatedByVenue;
        address owner;
        
    }

    struct Ticket{
        uint concertId;
        address owner;
        uint amountPaid;
        bool isAvailable;
        bool idAvailableForSale;
    }

    event NewArtist(bytes32 _name, uint _artistCategory,address _owner,uint _ticketSold);
    event NewVenue(bytes32 _name, uint _capacity, uint _standardComission,address _owner);

    mapping(uint => Artist) L_Artist;
    mapping(uint => Venue) L_Venue;
    mapping(uint => Concert) L_Concert;
    mapping(uint => Ticket) L_Ticket;

    uint artist_count = 1;
    uint venue_count = 1;
    uint concert_count = 1;
    uint ticket_count = 1;



    function createArtist(bytes32 _name, uint _artistCategory) public{
        Artist memory a = Artist(_name,_artistCategory,msg.sender,0);
        L_Artist[artist_count] = a;
        artist_count = artist_count + 1;
        emit NewArtist(_name,_artistCategory,msg.sender,0);
    }

    function artistsRegister(uint id) public view returns(Artist memory) {
        return(L_Artist[id]);
    }

    function modifyArtist(uint _artistId, bytes32 _name, uint _artistCategory, address payable _newOwner) 
    public OnlyOwnerArtist(_artistId){
        L_Artist[_artistId].name = _name;
        L_Artist[_artistId].artistCategory = _artistCategory;
        L_Artist[_artistId].owner = _newOwner;
    }

    modifier OnlyOwnerArtist(uint _artistId){
        require(L_Artist[_artistId].owner == msg.sender, "You are not the owner");
    }
    modifier OnlyOwnerVenue(uint _venueId){
        require(L_Venue[_venueId].owner == msg.sender, "You are not the owner");
    }
    modifier OnlyOwnerTicket(uint _ticketId){
        require(L_Ticket[_ticketId].owner == msg.sender, "You are not the owner");
    }

    function createVenue(bytes32 _name, uint _capacity, uint _standardComission) public {
        Venue memory v = Venue(_name,_capacity,_standardComission,msg.sender);
        L_Venue[venue_count] = v;
        venue_count = venue_count + 1;
        emit NewVenue(_name,_capacity,_standardComission,msg.sender);
    }

    function venueRegister(uint id) public view returns(Venue memory) {
        return(L_Venue[id]);
    }

    function modifyVenue(uint _venueId, bytes32 _name, uint _capacity, uint _standardComission, address _newOwner) public OnlyOwnerVenue(_venueId) {
       L_Venue[_venueId].name=_name;
       L_Venue[_venueId].capacity=_capacity;
       L_Venue[_venueId].standardComission=_standardComission;
       L_Venue[_venueId].owner=_newOwner;
    }

}