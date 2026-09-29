
-- List of resources with compat

return {
    xt_prisonjobs = (GetResourceState('morph_prisonjobs') == 'started'),
    randol_medical = (GetResourceState('randol_medical') == 'started'),
    qb_target = (GetResourceState('qb-target') == 'started'),
}