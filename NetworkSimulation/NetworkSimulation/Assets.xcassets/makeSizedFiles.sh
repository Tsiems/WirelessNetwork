svg=".svg"
png=".png"
ORIGINAL_SIZE=300

while getopts s:n: option
do
        case "${option}"
        in
                s) ORIGINAL_SIZE=${OPTARG};;
                n) NAME=${OPTARG};;
        esac
done

let "SIZE=$ORIGINAL_SIZE"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=$ORIGINAL_SIZE*2"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=$ORIGINAL_SIZE*3"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png
