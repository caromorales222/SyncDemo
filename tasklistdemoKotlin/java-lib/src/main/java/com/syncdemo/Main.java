package com.syncdemo;

public class Main {
    public static void main(String[] args) throws InterruptedException {

        /*Read input parameters:
        java -jar [].jar {userId} {insert|update|read}
         */
        var userid = "admin";
        var operation = "read";

        if (args.length >= 1)
            userid = args[0];
        if (args.length >= 2)
            operation = args[1];


        RealmTestRunner runner = new RealmTestRunner(userid);
        runner.start();

        if (operation.equals("insert"))
        {
            runner.insertTask();
        }

        else if (operation.equals("update"))
        {
            runner.updateTask();
        }

        else if (operation.equals("read"))
        {
            runner.readData();
        }
        runner.stop();
    }
}