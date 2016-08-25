package physics;


class CollisionFaces{


    public static inline var ALL:Int = 0xFFFFFFFF;
    public static inline var NONE:Int = 0x00000000;  

    public static inline var LEFT:Int = 1;   
    public static inline var RIGHT:Int = 1 << 1;  
    public static inline var UP:Int = 1 << 2;     
    public static inline var DOWN:Int = 1 << 3;  
    public static inline var CEILING:Int = UP;
    public static inline var FLOOR:Int = DOWN;
    public static inline var WALL:Int = LEFT | RIGHT;
    public static inline var ANY:Int = LEFT | RIGHT | UP | DOWN;
    public static inline var ALL_SIDES:Int = LEFT | RIGHT | UP | DOWN;

    public static inline var LEFT_PLAYER:Int = 1 << 4;      
    public static inline var RIGHT_PLAYER:Int = 1 << 5;      
    public static inline var UP_PLAYER:Int = 1 << 6;      
    public static inline var DOWN_PLAYER:Int = 1 << 7;      
    public static inline var PLAYER:Int = LEFT_PLAYER | RIGHT_PLAYER | UP_PLAYER | DOWN_PLAYER;
    public static inline var ALL_SIDES_PLAYER:Int = LEFT_PLAYER | RIGHT_PLAYER | UP_PLAYER | DOWN_PLAYER;

    public static inline var LEFT_SOLID:Int = 1 << 8;      
    public static inline var RIGHT_SOLID:Int = 1 << 9;      
    public static inline var UP_SOLID:Int = 1 << 10;      
    public static inline var DOWN_SOLID:Int = 1 << 11;      
    public static inline var SOLID:Int = LEFT_SOLID | RIGHT_SOLID | UP_SOLID | DOWN_SOLID;
    public static inline var ALL_SIDES_SOLID:Int = LEFT_SOLID | RIGHT_SOLID | UP_SOLID | DOWN_SOLID;

    public static inline var LEFT_ITEM:Int = 1 << 12;      
    public static inline var RIGHT_ITEM:Int = 1 << 13;      
    public static inline var UP_ITEM:Int = 1 << 14;      
    public static inline var DOWN_ITEM:Int = 1 << 15;      
    public static inline var ITEM:Int = LEFT_ITEM | RIGHT_ITEM | UP_ITEM | DOWN_ITEM;
    public static inline var ALL_SIDES_ITEM:Int = LEFT_ITEM | RIGHT_ITEM | UP_ITEM | DOWN_ITEM;

    public static inline var LEFT_ENEMY:Int = 1 << 16;      
    public static inline var RIGHT_ENEMY:Int = 1 << 17;      
    public static inline var UP_ENEMY:Int = 1 << 18;      
    public static inline var DOWN_ENEMY:Int = 1 << 19;      
    public static inline var ENEMY:Int = LEFT_ENEMY | RIGHT_ENEMY | UP_ENEMY | DOWN_ENEMY;
    public static inline var ALL_SIDES_ENEMY:Int = LEFT_ENEMY | RIGHT_ENEMY | UP_ENEMY | DOWN_ENEMY;

    public static inline var LEFT_MOVABLE:Int = 1 << 20;      
    public static inline var RIGHT_MOVABLE:Int = 1 << 21;      
    public static inline var UP_MOVABLE:Int = 1 << 22;      
    public static inline var DOWN_MOVABLE:Int = 1 << 23;      
    public static inline var MOVABLE:Int = LEFT_MOVABLE | RIGHT_MOVABLE | UP_MOVABLE | DOWN_MOVABLE;
    public static inline var ALL_SIDES_MOVABLE:Int = LEFT_MOVABLE | RIGHT_MOVABLE | UP_MOVABLE | DOWN_MOVABLE;


}

