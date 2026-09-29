return {
    Framework = 'auto',
    Inventory = 'morph_inv',
    UseOxLib = true,
    EnableAnimations = true,
    Animation = {
        dict = 'mp_common',
        anim = 'givetake1_a',
        flag = 49,
        duration = 2500
    },
    UseProgressBar = false,
    BoxSuffix = '-box',
    DefaultAmount = 50,
    Locale = {
        success = 'You opened the ammo box and received %s rounds',
        error_no_space = 'You don\'t have enough space in your inventory',
        error_generic = 'Something went wrong while opening the ammo box',
        error_no_output = 'Could not find output ammo for this box',
        cancelled = 'Action cancelled'
    },
    Debug = false
}