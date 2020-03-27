pragma solidity >0.5.0;
pragma experimental ABIEncoderV2;

contract ticketingSystem {
    struct Artist{
        bytes32 name;
        uint artistCategory;
        address payable owner;
        uint ticketSold;
    }

    struct Venue{
        bytes32 name;
        uint capacity;
        uint standardComission;
        address payable owner;
    }

    struct Concert{
        uint artistId;
        uint venueId;
        uint concertDate;
        uint ticketPrice;
        uint totalsoldTicket;
        uint totalMoneyCollected;
        bool validatedByArtist;
        bool validatedByVenue;
        address payable owner;
        
    }

    struct Ticket{
        uint concertId;
        address payable owner;
        uint amountPaid;
        bool isAvailable;
        bool idAvailableForSale;
    }

    event NewArtist(bytes32 _name, uint _artistCategory,address payable _owner,uint _ticketSold);
    event NewVenue(bytes32 _name, uint _capacity, uint _standardComission,address payable _owner);
    event NewConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice, address payable _owner);
    event NewTicket(uint _concertId, address _ticketOwner);

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

    function modifyVenue(uint _venueId, bytes32 _name, uint _capacity, uint _standardComission, address payable _newOwner) public OnlyOwnerVenue(_venueId) {
       L_Venue[_venueId].name=_name;
       L_Venue[_venueId].capacity=_capacity;
       L_Venue[_venueId].standardComission=_standardComission;
       L_Venue[_venueId].owner=_newOwner;
    }

    function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice) public {
        bool _validatedByArtist = msg.sender == L_Artist[_artistId].owner;
        bool _validatedByVenue = msg.sender == L_Venue[_venueId].owner;

        Concert memory c = Concert(_artistId,_venueId,_concertDate,_ticketPrice,0,0,_validatedByArtist,_validatedByVenue,msg.sender);
        L_Concert[concert_count] = c;
        concert_count = concert_count + 1;
        emit NewConcert(_artistId,_venueId,_concertDate,_ticketPrice,msg.sender);
    }

    function concertRegister(uint id) public view returns(Concert memory) {
        return(L_Concert[id]);
    }

    function validateConcert(uint _concertId) public {
        L_Concert[_concertId].validatedByArtist = msg.sender == L_Artist[L_Concert[_concertId].artistId].owner;
        L_Concert[_concertId].validatedByVenue = msg.sender == L_Venue[L_Concert[_concertId].venueId].owner;  
    }

    function emitTicket(uint _concertId, address payable _ticketOwner) public {
        require(msg.sender == L_Artist[L_Concert[_concertId].artistId].owner, "You have to buy the ticket");
        Ticket memory t = Ticket(_concertId, _ticketOwner, true, false, L_Concert[_concertId].ticketPrice);
        L_Ticket[ticket_count] = t;
        ticket_count = ticket_count + 1;
        L_Concert[_concertId].totalsoldTicket = L_Concert[_concertId].totalsoldTicket + 1;
        emit NewTicket(_concertId, _ticketOwner);
    }

    function useTicket(uint _ticketId) public {
        require(msg.sender == L_Ticket[_ticketId].owner,"You are not the owner of this ticket");
        require(block.timestamp >= L_Concert[L_Ticket[_ticketId].concertId].concertDate - 1 days && block.timestamp >= L_Concert[L_Ticket[_ticketId].concertId].concertDate + 1 days, "The Date doesn't match the requirement");
        require(L_Concert[L_Ticket[_ticketId].concertId].validatedByVenue,"This ticket has not been validate");
        L_Ticket[_ticketId].isAvailable = false;
    }

    function buyTicket(uint _concertId) public payable{
        require(msg.value == L_Concert[_concertId].ticketPrice, "The amount doesn't match the ticket price");
        L_Concert[_concertId].owner.transfer(msg.value);
        L_Concert[_concertId].totalMoneyCollected = L_Concert[_concertId].totalMoneyCollected + msg.value;
        L_Artist[L_Concert[_concertId].artistId].ticketSold = L_Artist[L_Concert[_concertId].artistId].ticketSold + 1;
        emitTicket(_concertId, msg.sender);

    }

    



}