trigger ServiceResourceSkillTrigger on ServiceResourceSkill (before insert) {
	System.debug('hola');
}