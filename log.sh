echo "Server Log"
tail -n $1 ./logs/server.log
echo ""
echo ""
echo "Loader Log"
tail -n $1 ./logs/loader.log
echo ""
echo ""
echo "Run Log"
tail -n $1 ./logs/run.log
echo ""
echo ""
echo "Victim Log"
tail -n $1 ./logs/victim.log
echo ""
