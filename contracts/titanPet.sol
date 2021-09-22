// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";

contract TitanPet is Ownable{
    
    enum attr {
        HUNGER,
        THIRST,
        HEALTH,
        HAPPINESS,
        ENERGY,
        CLEANLINESS
    }
    
    // Stats mapping
    mapping(attr=>uint) attributes;
    // Attribute update timestamps
    mapping(attr=>uint) attributeChanges;
    
    // Status and attributes
    string name;
    string eulogy;
    bool asleep;
    bool buried;
    
    // Timestamps
    uint bornTimestamp;
    uint buriedTimestamp;
    uint sleepTime;
    uint wakeUpTime;
    


    modifier onlyDead() {
        require(!isAlive(), "I'm alive");
        _;
    }
    
    modifier onlyAlive() {
        require(isAlive(), "Dead. RIP.");
        _;
    }
    
    modifier onlyAwake() {
        require(!asleep, "I'm asleep");
        _;
    }
    
    modifier onlyAsleep() {
        require(asleep, "I'm awake");
        _;
    }
    
    event Born(uint256 timeStamp);
    event ThankYou(address who, uint256 amount);
    
    constructor(string memory p_name) {
        name = p_name;
        attributes[attr.HUNGER] = 0;
        attributes[attr.THIRST] = 0;
        attributes[attr.HEALTH] = 60 + ((block.timestamp ^ block.difficulty) % 40);
        attributes[attr.HAPPINESS] = 60 + (block.timestamp % 40);
        attributes[attr.ENERGY] = 100;
        attributes[attr.CLEANLINESS] = 60 + ((block.timestamp ^ block.number) % 40);
        asleep = false;
        buried = false;
        bornTimestamp = block.timestamp;
        emit Born(block.timestamp);
    }
    
    /* INTERACTIONS */
    function buyApple() external onlyAwake onlyAlive onlyOwner{
        require (getCleanliness()>=30,"I'm too dirty to eat");
        require (getHunger()>=30,"I'm not hungry");
        setAttr(attr.HUNGER,-20);
        setAttr(attr.THIRST,-5);
        setAttr(attr.CLEANLINESS,-10);
        setAttr(attr.HEALTH,5);
    }
    
    function buyCake() external onlyAwake onlyAlive onlyOwner{
        require (getHunger()>=30,"I'm stuffed!");
        require (getCleanliness()>=30,"I'm too dirty to eat!");
        setAttr(attr.HAPPINESS,10 + int(getHunger()/10));
        setAttr(attr.HUNGER,-30);
        setAttr(attr.THIRST,10);
        setAttr(attr.CLEANLINESS,-20);
        setAttr(attr.HEALTH,-10);
        setAttr(attr.ENERGY,5);
    }
    
    function buyVegetables() external onlyAwake onlyAlive onlyOwner{
        require (attributes[attr.CLEANLINESS]>=30,"I'm too dirty to eat");
        require (attributes[attr.HUNGER]>=30,"I'm stuffed!");
        setAttr(attr.HUNGER,-20);
        setAttr(attr.CLEANLINESS,-10);
        setAttr(attr.HEALTH, 15);
        setAttr(attr.HAPPINESS,-10);
    }
    
    function buyMeal() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HUNGER,-50);
        setAttr(attr.THIRST,-50);
        setAttr(attr.CLEANLINESS,-15);
        setAttr(attr.HEALTH,10);
        setAttr(attr.HAPPINESS,int(getHunger()/10));
    }
    
    function buyWater() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HAPPINESS, int(getThirst()/10));
        setAttr(attr.THIRST,-50);
        setAttr(attr.HEALTH,10);
    }

    function buySoda() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HAPPINESS, 15 + int(getThirst()/10));
        setAttr(attr.HUNGER,-10);
        setAttr(attr.THIRST,-50);
        setAttr(attr.CLEANLINESS,-15);
        setAttr(attr.HEALTH,-10);
        setAttr(attr.ENERGY,5);
    }

    function buyFruitJuice() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HAPPINESS,5 + int(getThirst()/10));
        setAttr(attr.HUNGER,-10);
        setAttr(attr.THIRST,-30);
        setAttr(attr.CLEANLINESS,-10);
        setAttr(attr.HEALTH,15);
        setAttr(attr.ENERGY,5);
    }
    
    function buyToy() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HAPPINESS,30);
        setAttr(attr.ENERGY,-20);
        setAttr(attr.CLEANLINESS,-20);
    }
    
    function buyMedicine() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HEALTH,50);
        setAttr(attr.HAPPINESS,-30);
        setAttr(attr.ENERGY,-30);
    }
    
    function brush() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.CLEANLINESS,20);
        setAttr(attr.HAPPINESS,-10);
    }
    
    function wash() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.CLEANLINESS,50);
        setAttr(attr.HAPPINESS,-20);
    }
    
    function walk() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HEALTH,15);
        setAttr(attr.HAPPINESS,10);
        setAttr(attr.ENERGY,-20);
    }
    
    function exercise() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HEALTH,25);
        setAttr(attr.HAPPINESS,10);
        setAttr(attr.ENERGY,-30);
        setAttr(attr.THIRST,30); // require thirst <70 so you cant exercise to death (goes for other stuff too) 
    }
    
    function sleep() external onlyAwake onlyAlive onlyOwner{
        require (getEnergy()<=20, "I'm not sleepy");
        sleepTime = block.timestamp;
        asleep = true;
    }
    
    function wakeUp() external onlyAsleep onlyAlive onlyOwner{
        require (asleep, "I'm already awake");
        require ((block.timestamp - sleepTime) > 30 minutes, "ZzzZzzz...");
        wakeUpTime = block.timestamp;
        
        // Underslept
        if ((wakeUpTime - sleepTime) > 30 minutes && (wakeUpTime - sleepTime) <= 1 hours) {
            setAttr(attr.ENERGY,30 + (wakeUpTime % 70));
            setAttr(attr.HAPPINESS,-10);
            setAttr(attr.HEALTH,-10);
        }
        
        // Slept okay
        if ((wakeUpTime - sleepTime) > 1 hours && (wakeUpTime - sleepTime) <= 2 hours) {
            attributes[attr.ENERGY] = 50 + (wakeUpTime % 50);
        }
        
        // Well slept
        if ((wakeUpTime - sleepTime) > 2 hours) {
            attributes[attr.ENERGY] = 70 + (wakeUpTime % 30);
            setAttr(attr.HAPPINESS, getHappiness()+10);
            attributes[attr.HEALTH] += 15;
        }

    }

    function setAttr(attr p_attribute, int p_value) internal {
        if (p_value<0) {
            p_value=0;
        }
        if (p_value>100) {
            p_value=100;
        }
        attributes[p_attribute] = p_value;
        attributeChanges[p_attribute] = block.timestamp;
    }

    
    // Get functions
    function getHunger() public view returns(uint){
        if (asleep){
            return attributes[attr.HUNGER];
        }
        else {
            // time decay function
            return attributes[attr.HUNGER];
        }
    }
    
    function getThirst() public view returns(uint){
        if (asleep){
            return attributes[attr.THIRST];
        }
        else {
            // time decay function
            return attributes[attr.THIRST];
        }
    }
    
    function getCleanliness() public view returns(uint){
        if (asleep){
            return attributes[attr.CLEANLINESS];
        }
        else {
            // time decay function
            return attributes[attr.CLEANLINESS];
        }
    }
 
    function getHappiness() public view returns(uint){
        return attributes[attr.HAPPINESS];
    }   
    
    function getMinutesAsleep() public view onlyAsleep returns(uint) {
        return (block.timestamp-sleepTime)/1 minutes;
    }
    
    function getEnergy() public view returns(uint){
        return attributes[attr.ENERGY];
    }
    
    function getHealth() public view returns(uint){
        return attributes[attr.HEALTH];
    }
    
    function getEulogy() public view returns(string memory){
        return eulogy;
    }
    
    function isBuried() external view returns(bool){
        return buried;
    }
    
    function isAlive() public view returns(bool){
        return (getHunger() < 100 
        && getThirst() < 100 
        && getHealth() > 0);
    }
    
    function bury(string calldata p_eulogy) external onlyDead onlyOwner{
        require (!buried);
        buried = true;
        buriedTimestamp = block.timestamp;
        eulogy = p_eulogy;
    }
    
    function revive() external onlyDead onlyOwner{
        attributes[attr.HEALTH]=100;
    }
    
    function kill() external onlyAlive {
        attributes[attr.HEALTH]=0;
    }
    
}