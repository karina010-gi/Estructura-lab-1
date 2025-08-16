#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3

# Archivos
target_file="exercises.c"
testcode="test.c"
LOG="log"

# Encabezado de log
echo "$(date): " >> "$LOG"

# Compilación
echo "Compiling with: gcc $testcode -Wall -Werror -o a.out" >&3
echo "Compiling with: gcc $testcode -Wall -Werror -o a.out" >> "$LOG"

if gcc "$testcode" -Wall -Werror -o a.out 2>>"$LOG"; then
  # Ejecución y registro de tests
  echo "Executing: ./a.out" >&3

  # Capturamos salida y estado de ejecución
  OUTPUT=$(./a.out 2>&1)
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    # Contar OK/FAILED sin ejecutar dos veces
    OK=$(printf "%s" "$OUTPUT" | grep -c 'OK')
    FAILED=$(printf "%s" "$OUTPUT" | grep -c 'FAILED')

    echo " tests: $OK|$FAILED" >> "$LOG"
    printf "%s\n" "$OUTPUT" | tail -n1 >> "$LOG"

    # Mostrar salida al usuario
    printf "%s\n" "$OUTPUT" >&3
  else
    echo "Errors in execution =O" >&3
    echo "Execution failed" >> "$LOG"
    printf "%s\n" "$OUTPUT" >> "$LOG"

    # Ayuda para depuración
    echo "Recompilando con símbolos de depuración..." >&3
    gcc -g "$testcode" -o a.out >&3
    gdb -silent -ex='set disable-randomization off' -ex='set confirm off' -ex='run' -ex=quit a.out >&3
    exit 1
  fi

else
  echo "Compilation with errors :c" >&3
  echo "Compilation failed" >> "$LOG"

  # Mostrar errores por pantalla para el usuario
  gcc "$testcode" -Wall -Werror -o a.out >&3
  exit 1
fi
