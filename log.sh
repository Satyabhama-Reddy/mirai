echo "Server Log"
tail -n 10 ./logs/server.log
echo ""
echo ""
echo "Run Log"
tail -n 10 ./logs/loader.log
echo ""
echo ""
echo "Loader Log"
tail -n 10 ./logs/run.log
echo ""
echo ""
echo "victim Log"
tail -n 10 ./logs/victim.log
echo ""
