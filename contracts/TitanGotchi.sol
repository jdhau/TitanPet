// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TitanPet is Ownable {
    
    address constant titanAddress=0x1cd2ffDb2CbDd10e1124841038A8ed6603f91016;
    
    modifier costs(uint p_cost){
        ERC20Burnable titanToken = ERC20Burnable(titanAddress); // TESTNET TOKEN
        require (titanToken.allowance(msg.sender, address(this)) >= p_cost, "Insufficient approved TITAN balance");
        
        titanToken.transferFrom(msg.sender, address(this), p_cost);
        titanToken.burn(p_cost / 2);
        _;
    }
    
    enum attr {
        HUNGER,
        THIRST,
        UNHEALTHINESS,
        UNHAPPINESS,
        TIREDNESS,
        DIRTINESS,
        HUNGER_FACTOR,
        THIRST_FACTOR,
        UNHEALTHINESS_FACTOR,
        UNHAPPINESS_FACTOR,
        TIREDNESS_FACTOR,
        DIRTINESS_FACTOR
    }
    
    // Stats mapping
    mapping(attr=>int) attributes;
    
    // Attribute update timestamps
    mapping(attr=>uint) attributeChanges;
    
    // Status and attributes
    uint id;
    string name;
    bool asleep = false;
    
    // Timestamps
    uint bornTimestamp = block.timestamp;
    uint buriedTimestamp;
    uint sleepTime;
    
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
    
    constructor(string memory p_name, uint p_id) {
        name = p_name;
        id = p_id;
        setAttr(attr.HUNGER,0);
        setAttr(attr.THIRST,0);
        setAttr(attr.UNHEALTHINESS, int(block.timestamp ^ block.difficulty) % 40);
        setAttr(attr.UNHAPPINESS, int(block.timestamp) % 40);
        setAttr(attr.TIREDNESS, 0);
        setAttr(attr.DIRTINESS, int(block.timestamp ^ block.number) % 40);
        
        setAttr(attr.HUNGER_FACTOR,0);
        setAttr(attr.THIRST_FACTOR,0);
        setAttr(attr.UNHEALTHINESS_FACTOR,0);
        setAttr(attr.UNHAPPINESS_FACTOR,0);
        setAttr(attr.TIREDNESS_FACTOR,0);
        setAttr(attr.DIRTINESS_FACTOR,0);

        emit Born(block.timestamp);
    }
    
    /* INTERACTIONS */
    function buyApple() external onlyAwake onlyAlive onlyOwner{
        require (getHunger()>=30,"Not hungry");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");
        
        setAttr(attr.HUNGER,getHunger()-20);
        setAttr(attr.THIRST,getThirst()-10);
        setAttr(attr.DIRTINESS,getDirtiness()+15);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
    }
    
    function buyCake() external onlyAwake onlyAlive onlyOwner{
        require (getHunger()>=30,"Not hungry");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");
        
        setAttr(attr.UNHAPPINESS,getUnHappiness()+ 10 + getHunger()/10);
        setAttr(attr.HUNGER,getHunger()-30);
        setAttr(attr.THIRST,getThirst()+10);
        setAttr(attr.DIRTINESS,getDirtiness()+20);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()+10);
        setAttr(attr.TIREDNESS,getTiredness()+10);
    }
    
    function buyVegetables() external onlyAwake onlyAlive onlyOwner{
        require (getHunger()>=30,"Not hungry");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");
        
        setAttr(attr.HUNGER,getHunger()-20);
        setAttr(attr.DIRTINESS,getDirtiness()+10);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-15);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+10);
    }
    
    function buyMeal() external onlyAwake onlyAlive onlyOwner{
        require (getHunger()>=30,"Not hungry");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");
        
        setAttr(attr.HUNGER,0);
        setAttr(attr.THIRST,getThirst()/2);
        setAttr(attr.DIRTINESS,getDirtiness()+15);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
        setAttr(attr.UNHAPPINESS,getUnHappiness()-getHunger()/10);
    }
    
    function buyWater() external onlyAwake onlyAlive{
        require (getThirst()>=30,"Not thirsty");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");
        
        setAttr(attr.UNHAPPINESS,getUnHappiness()-getThirst()/10);
        setAttr(attr.THIRST,getThirst()-50);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
    }

    function buySoda() external onlyAwake onlyAlive{
        require (getThirst()>=30,"Not thirsty");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");
        
        setAttr(attr.UNHAPPINESS,getUnHappiness()-(15 + getThirst()/10));
        setAttr(attr.HUNGER,getHunger()-10);
        setAttr(attr.THIRST,getThirst()-50);
        setAttr(attr.DIRTINESS,getDirtiness()+15);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()+10);
        setAttr(attr.TIREDNESS,getTiredness()+5);
    }

    function buyFruitJuice() external onlyAwake onlyAlive{
        require (getThirst()>=30,"Not thirsty");
        require (getDirtiness()<80,"Too dirty");
        require (getTiredness()<80,"Too tired");      
        
        setAttr(attr.UNHAPPINESS,getUnHappiness()-(5 + getThirst()/10));
        setAttr(attr.HUNGER,getHunger()-10);
        setAttr(attr.THIRST,getThirst()-30);
        setAttr(attr.DIRTINESS,getDirtiness()+10);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-15);
        setAttr(attr.TIREDNESS,getTiredness()+5);
    }
    
    function buyToy() external onlyAwake onlyAlive{
        require (getTiredness()<70,"Too tired");
        require (getHunger()<80,"Too hungry");
        require (getThirst()<80,"Too thirsty");
        require (getDirtiness()<70,"Too dirty"); 
        
        setAttr(attr.UNHAPPINESS,getUnHappiness()-50);
        setAttr(attr.TIREDNESS,getTiredness()+20);
        setAttr(attr.DIRTINESS,getDirtiness()+20);
    }
    
    function buyMedicine() external onlyAwake onlyAlive{
        require (getUnHealthiness()>50,"Healthy"); 
        
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-50);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+30);
        setAttr(attr.TIREDNESS,getTiredness()+30);
    }
    
    function brush() external onlyAwake onlyAlive{
        require (getDirtiness()>70,"Too dirty"); 
        setAttr(attr.DIRTINESS,getDirtiness()-20);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+10);
    }
    
    function wash() external onlyAwake onlyAlive{
        setAttr(attr.DIRTINESS,getDirtiness()-50);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+20);
          setAttr(attr.TIREDNESS,getTiredness()+10);     
    }
    
    function walk() external onlyAwake onlyAlive{
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-15);
        setAttr(attr.UNHAPPINESS,getUnHappiness()-10);
        setAttr(attr.TIREDNESS,getTiredness()+20);
    }
    
    function exercise() external onlyAwake onlyAlive{
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-25);
        setAttr(attr.UNHAPPINESS,getUnHappiness()-10);
        setAttr(attr.TIREDNESS,getTiredness()+30);
        setAttr(attr.THIRST,getThirst()+30); // require thirst <70 so you cant exercise to death (goes for other stuff too) 
    }
    
    function sleep() external onlyAwake onlyAlive{
        require (getTiredness()>=75, "I'm not sleepy");
        require (getThirst()<75,"Too thirsty!");
        require (getHunger()<75,"Too hungry!");
        
        sleepTime = block.timestamp;
        asleep = true;
    }
    
    function wakeUp() external onlyAsleep onlyAlive{
        require (asleep, "I'm already awake");
        require (getMinutesAsleep() > 3 hours, "ZzzZzzz...");
        
        // Underslept
        if (getMinutesAsleep() <= 5 hours) {
            setAttr(attr.TIREDNESS,20+int(block.timestamp % 50));
            setAttr(attr.UNHAPPINESS,getUnHappiness()+20);
            setAttr(attr.UNHEALTHINESS,getUnHealthiness()+10);
        }
        
        // Slept okay
        if (getMinutesAsleep() > 5 hours && getMinutesAsleep() <= 7 hours) {
            setAttr(attr.TIREDNESS,10+int(block.timestamp % 30));
        }
        
        // Well slept
        if (getMinutesAsleep() > 7 hours) {
            setAttr(attr.TIREDNESS,int(block.timestamp) % 20);
            setAttr(attr.UNHAPPINESS,getUnHappiness()-20);
            setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
        }
        
        setAttr(attr.THIRST,getThirst()+20);
        setAttr(attr.HUNGER,getHunger()+20);

    }


    // Param has to be an int to prevent possible underflow
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
    function getHunger() public view returns(int){
        if (asleep){
            return attributes[attr.HUNGER];
        }
        else {
            // time decay function
            return attributes[attr.HUNGER];
        }
    }
    
    function getThirst() public view returns(int){
        if (asleep){
            return attributes[attr.THIRST];
        }
        else {
            // time decay function
            return attributes[attr.THIRST];
        }
    }
    
    function getDirtiness() public view returns(int){
        if (asleep){
            return attributes[attr.DIRTINESS];
        }
        else {
            // time decay function
            return attributes[attr.DIRTINESS];
        }
    }
 
    function getUnHappiness() public view returns(int){
        if (asleep){
            return attributes[attr.UNHAPPINESS];
        }
        else {
            // time decay function
            return attributes[attr.UNHAPPINESS];
        }        
    }   
    
    function getMinutesAsleep() public view onlyAsleep returns(uint) {
        return (block.timestamp-sleepTime)/1 minutes;
    }
    
    function getTiredness() public view returns(int){
        return attributes[attr.TIREDNESS];
    }
    
    function getUnHealthiness() public view returns(int){
        return (100-attributes[attr.UNHEALTHINESS]);
    }
    
    function isAlive() public view returns(bool){
        return (getHunger() < 100 
        && getThirst() < 100 
        && getUnHealthiness() > 0);
    }

    
    function revive() external onlyDead onlyOwner{
        attributes[attr.UNHEALTHINESS]=100;
    }
    
    function kill() external onlyAlive onlyOwner {
        attributes[attr.UNHEALTHINESS]=0;
    }
    
    function withDraw() onlyOwner external {
        ERC20Burnable titanToken = ERC20Burnable(titanAddress);
        titanToken.transfer(msg.sender,titanToken.balanceOf(address(this)));
    }
    
}