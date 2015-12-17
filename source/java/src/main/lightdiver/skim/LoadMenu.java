package main.lightdiver.skim;

import main.lightdiver.skim.DAO.SystemInfoDAO;
import main.lightdiver.skim.entity.TreeNodeMenu;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.model.LocalizationBean;

import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.swing.tree.TreeNode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.ResourceBundle;
import java.util.logging.Logger;

/**
 * Created by Serj on 20.11.2015.
 */
public class LoadMenu {
    private final static Logger logger = Logger.getLogger(LoadMenu.class.getName());
    private List<TreeNode> footerMenu1 = null;
    private List<TreeNode> footerMenu2 = null;

    public void LoadMenuFooter(){
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        ResourceBundle msg = LocalizationBean.getTextDependLangList().get(externalContext.getSessionMap().get("electLocale"));

        //System.out.println("Load getFooterMenu1");
        TreeNodeMenu treeNode1 = new TreeNodeMenu("simple", msg.getString("menu.footer1.skimread"), "#", false);

        TreeNodeMenu treeNode11 = new TreeNodeMenu("lesson", msg.getString("menu.footer1.lessons"), "#", false);
        TreeNodeMenu treeNode111 = new TreeNodeMenu("lesson", msg.getString("menu.footer1.lesson1"), "#", true);
        TreeNodeMenu treeNode112 = new TreeNodeMenu("lesson", msg.getString("menu.footer1.lesson2"), "#", false);
        treeNode11.addChild(treeNode111);
        treeNode11.addChild(treeNode112);

        TreeNodeMenu treeNode112p = new TreeNodeMenu("practice", msg.getString("menu.footer1.practices"), "#", false);
        TreeNodeMenu treeNode112p1 = new TreeNodeMenu("practice", msg.getString("menu.footer1.practice1"), "#", true);
        treeNode112p.addChild(treeNode112p1);

        treeNode112.addChild(treeNode112p);

        TreeNodeMenu treeNode12 = new TreeNodeMenu("test", msg.getString("menu.footer1.testing"), "#", true);


        treeNode1.addChild(treeNode11);
        treeNode1.addChild(treeNode12);

        if (footerMenu1==null) { footerMenu1 = new ArrayList<>();}
        else{footerMenu1.clear();}
        footerMenu1.add(treeNode1);


        //System.out.println("Load getFooterMenu2");
        TreeNodeMenu treeNode2 = new TreeNodeMenu("simple", msg.getString("menu.footer2.main"), "main.xhtml", true);
        TreeNodeMenu treeNode3 = new TreeNodeMenu("simple", msg.getString("menu.footer2.article"), "#", true);
        TreeNodeMenu treeNode4 = new TreeNodeMenu("simple", msg.getString("menu.footer2.about"), "about.xhtml", true);
        TreeNodeMenu treeNode5 = new TreeNodeMenu("simple", msg.getString("menu.footer2.contacts"), "#", true);
        TreeNodeMenu treeNode6 = new TreeNodeMenu("simple", msg.getString("menu.footer2.registration"), "register.xhtml", true);
        TreeNodeMenu treeNode7 = new TreeNodeMenu("simple", msg.getString("menu.footer2.literature"), "#", true);


        footerMenu2 = new ArrayList<>();
        footerMenu2.add(treeNode2);
        footerMenu2.add(treeNode3);
        footerMenu2.add(treeNode4);
        footerMenu2.add(treeNode5);
        footerMenu2.add(treeNode6);
        footerMenu2.add(treeNode7);
    }

    public  List<TreeNode> getFooterMenu1(){
        if (footerMenu1 == null ) {
            LoadMenuFooter();
        }
        return footerMenu1;
    }
    public  List<TreeNode> getFooterMenu2(){
        if (footerMenu2 == null) {
            LoadMenuFooter();
        }
        return footerMenu2;
    }
    public static HashMap<String, String> getLangs(){
        HashMap<String, String> langs;
        try {
            return SystemInfoDAO.getLangs();
        } catch (BaseNotConnect baseNotConnect) {
            logger.severe("Don't get support lang. Set UA Default");
            langs = new HashMap<>();
            langs.put("UA", "Українська");
            return langs;
        }
    }
}
