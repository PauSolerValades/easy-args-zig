
Com hem de parsejar i omplir l'struct amb commmads?

Posar restriccions sobre on es poden posar commands? 
Jo crec que no té senit que tinguis programa command (arg) command


= Exemple 1

tally track start "super projecte" --project 1 -v

def parse_value_rec(definition: Struct):
  result = createDefinition()
  
  iterator = std.process.args()
  
  // fill the defaults

  while (args.next()) |arg|:
    // check commands
    for (command) in EnumCommands:
      if (arg == command): 
        new_iterator = iterator[]
        parse_value_rec(definition, new_iterator)
  

def parse_value(defnition: struct):
  result = createDefinition()
  
  iterator = std.process.args()
  
  // fill the defaults
  
  (...)
  // find out how many commands does the definition have: check for every union we have if the commands have that order
  commands = []
  while (args.next()) |arg|:
    // hauria de ser comptime, que depengui del com s'hagi generat el tipus
    // EG: si hi poden haver-hi dos commands seguits, hauriem de tenir una manera de saber que s'ha de buscar command 1, command 2
     

