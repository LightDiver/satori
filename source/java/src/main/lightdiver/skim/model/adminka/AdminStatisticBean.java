package main.lightdiver.skim.model.adminka;

import main.lightdiver.skim.Users;
import main.lightdiver.skim.entity.UsersAction;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Created by Serj on 09.12.2015.
 */
@ManagedBean
@ViewScoped
public class AdminStatisticBean implements Serializable{
    private List<UsersAction> allUsersAction = null;
    private Date startDate;
    private Date endDate;
    private Integer userId;
    private Integer successActionYes;

    @PostConstruct
    void Init(){
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_MONTH, 1);
        startDate = calendar.getTime();
        calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
        endDate = calendar.getTime();
        //System.out.println("startDate=" + startDate + " endDate="+endDate);
    }

    public List<UsersAction> getAllUsersAction() {
        if (allUsersAction == null){
            allUsersAction = Users.getUsersAction(startDate, endDate, userId, successActionYes);
        }
        //System.out.println("Size allUsersAction:" + allUsersAction.size());
        return allUsersAction;
    }

    public void setAllUsersAction(List<UsersAction> allUsersAction) {
        this.allUsersAction = allUsersAction;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getSuccessActionYes() {
        return successActionYes;
    }

    public void setSuccessActionYes(int successActionYes) {
        this.successActionYes = successActionYes;
    }
}
